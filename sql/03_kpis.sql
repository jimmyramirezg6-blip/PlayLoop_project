

-- CPI BY CHANNEL
WITH inst AS (SELECT canal_adquisicion AS canal, COUNT(*) AS n FROM users GROUP BY canal), 
	 spend AS (SELECT canal, SUM(gasto::NUMERIC) AS g FROM ua_spend GROUP BY canal)
SELECT
	inst.canal, 
	inst.n AS upload, 
	ROUND(spend.g / inst.n, 2) AS cpi
FROM inst
JOIN spend USING (canal)
ORDER BY cpi;

-- INSTALLS (PLAYERS PER CHANNEL) AND CPI (SPEND/INS)
WITH spend AS (
    SELECT canal, SUM(gasto::NUMERIC) AS total_spend FROM ua_spend GROUP BY canal
)
SELECT
    u.canal_adquisicion,
    COUNT(*) AS installs,
    ROUND(COALESCE(s.total_spend, 0), 2) AS spend,
    ROUND(COALESCE(s.total_spend, 0) / COUNT(*), 2) AS cpi
FROM users u
LEFT JOIN spend s ON u.canal_adquisicion = s.canal          
GROUP BY u.canal_adquisicion, s.total_spend
ORDER BY installs DESC;

-- D1 RETENTION BY CHANNEL
SELECT
	u.canal_adquisicion, 
	COUNT(DISTINCT u.user_id) AS cohort,
	ROUND(100.0 * COUNT(DISTINCT s.user_id) / COUNT(DISTINCT u.user_id), 2) AS retetion_d1_pct
FROM users u
LEFT JOIN sessions s 
		ON u.user_id = s.user_id 
		AND (s.fecha::DATE - u.fecha_instalacion::DATE) = 1
WHERE (DATE '2024-07-22' - u.fecha_instalacion::DATE) >=1
GROUP BY canal_adquisicion
ORDER BY retetion_d1_pct DESC; 

-- D7 RETETION BY CHANNEL
SELECT 
	u.canal_adquisicion, 
	COUNT(DISTINCT u.user_id) AS cohort, 
	ROUND(100.0 * COUNT(DISTINCT s.user_id) / COUNT(DISTINCT u.user_id), 2) AS retetion_d7_pct
FROM users u
LEFT JOIN sessions s 
	ON u.user_id = s.user_id
	AND (s.fecha::DATE - u.fecha_instalacion) = 7
WHERE (DATE '2024-07-22' - u.fecha_instalacion::DATE) >= 7
GROUP BY canal_adquisicion
ORDER BY retetion_d7_pct;

-- PAYER CONVERSION BY CHANNEL
WITH payers AS (
	SELECT DISTINCT user_id FROM purchases
)
SELECT
	u.canal_adquisicion, 
	COUNT(u.user_id) AS installs, 
	COUNT(p.user_id) AS payers,
	ROUND(100.0 * COUNT(DISTINCT p.user_id) / COUNT(DISTINCT u.user_id), 2) AS conversion_pct
FROM users u
LEFT JOIN payers p ON u.user_id = p.user_id
GROUP BY u.canal_adquisicion
ORDER BY conversion_pct DESC;

-- LTV BY CHANNEL
WITH inst AS (
	SELECT canal_adquisicion, COUNT(*) AS n FROM users GROUP BY canal_adquisicion
),
iap AS (
	SELECT u.canal_adquisicion, SUM(p.importe ) * 0.70 AS net
	FROM purchases p 
	JOIN users u ON p.user_id = u.user_id
	GROUP BY u.canal_adquisicion
), 
ads AS (
	SELECT u.canal_adquisicion, SUM(a.ingreso) AS ads 
	FROM ad_revenue a
	JOIN users u ON a.user_id = u.user_id
	GROUP BY u.canal_adquisicion
)
SELECT 
	inst.canal_adquisicion AS channel, 
	inst.n AS installs, 
	ROUND((COALESCE(iap.net::NUMERIC, 0) + COALESCE(ads.ads::NUMERIC,0)) / inst.n, 3) AS net_ltv
FROM inst
LEFT JOIN iap USING (canal_adquisicion)
LEFT JOIN ads USING (canal_adquisicion)
ORDER BY net_ltv DESC;

-- ROAS BY CHANNEL = LTV /CPI 

WITH inst AS (
	SELECT canal_adquisicion, COUNT(*) AS n FROM users GROUP BY canal_adquisicion
), 
spend AS (
	SELECT canal AS canal_adquisicion, SUM(gasto) AS spend FROM ua_spend GROUP BY canal
), 
iap AS (
	SELECT u.canal_adquisicion, SUM(p.importe) * 0.70 AS net
	FROM purchases p 
	JOIN users u ON p.user_id = u.user_id
	GROUP BY canal_adquisicion
), 
ads AS (
	SELECT u.canal_adquisicion, SUM(a.ingreso) AS ads
	FROM ad_revenue a
	JOIN users u ON a.user_id = u.user_id
	GROUP BY canal_adquisicion
)
SELECT 
	inst.canal_adquisicion, 
	ROUND(spend.spend::NUMERIC  / inst.n::NUMERIC, 2) AS cpi, 
	ROUND((COALESCE(iap.net::NUMERIC, 0) + COALESCE(ads.ads::NUMERIC,0))/inst.n::NUMERIC, 2) AS ltv, 
	ROUND(	
		((COALESCE(iap.net::NUMERIC,0) + COALESCE(ads.ads::NUMERIC, 0)) /inst.n::NUMERIC)/(spend.spend::NUMERIC/inst.n::NUMERIC)
	,2) AS roa
FROM inst 
JOIN spend USING (canal_adquisicion)
LEFT JOIN iap USING(canal_adquisicion)
LEFT JOIN ads USING (canal_adquisicion)
WHERE spend.spend > 0
ORDER BY roa;

-- COMPLETE TABLE - CPI, RET, CONV AND ROAS
WITH inst AS (
    SELECT canal_adquisicion, COUNT(*) AS n 
    FROM users 
    GROUP BY canal_adquisicion
), 
spend AS (
    SELECT canal AS canal_adquisicion, SUM(gasto) AS spend 
    FROM ua_spend 
    GROUP BY canal_adquisicion
),
d7 AS (
    SELECT 
        u.canal_adquisicion,
        ROUND(100.0 * COUNT(DISTINCT s.user_id) / COUNT(DISTINCT u.user_id), 2) AS ret_d7
    FROM users u
    LEFT JOIN sessions s 
        ON u.user_id = s.user_id 
       AND (s.fecha::DATE - u.fecha_instalacion::DATE) = 7
    WHERE (DATE '2024-07-22' - u.fecha_instalacion::DATE) >= 7
    GROUP BY u.canal_adquisicion
), 
conv AS (
    SELECT 
        u.canal_adquisicion, 
        ROUND(100.0 * COUNT(DISTINCT p.user_id) / COUNT(DISTINCT u.user_id), 2) AS conv_pct
    FROM users u 
    LEFT JOIN (SELECT DISTINCT user_id FROM purchases) p ON u.user_id = p.user_id
    GROUP BY u.canal_adquisicion
), 
iap AS (
    SELECT u.canal_adquisicion, SUM(p.importe::NUMERIC) * 0.70 AS net 
    FROM purchases p 
    JOIN users u ON p.user_id = u.user_id 
    GROUP BY u.canal_adquisicion
), 
ads AS (
    SELECT u.canal_adquisicion, SUM(a.ingreso) AS ads 
    FROM ad_revenue a 
    JOIN users u ON a.user_id = u.user_id 
    GROUP BY u.canal_adquisicion
)

SELECT 
    inst.canal_adquisicion, 
    inst.n AS installs, 
    ROUND(COALESCE(spend.spend::NUMERIC, 0) / inst.n::NUMERIC, 2) AS cpi, 
    d7.ret_d7, 
    conv.conv_pct, 
    ROUND((COALESCE(iap.net::NUMERIC, 0) + COALESCE(ads.ads::NUMERIC, 0)) / NULLIF(spend.spend::NUMERIC, 0), 2) AS roas
FROM inst
LEFT JOIN spend USING(canal_adquisicion)
LEFT JOIN d7 USING(canal_adquisicion)
LEFT JOIN conv USING(canal_adquisicion)
LEFT JOIN iap USING(canal_adquisicion)
LEFT JOIN ads USING(canal_adquisicion)
ORDER BY canal_adquisicion;

-- PROFIT BY CHANNEL 
WITH inst AS (
    SELECT canal_adquisicion, COUNT(*) AS n 
    FROM users 
    GROUP BY canal_adquisicion
), 
spend AS (
    SELECT canal AS canal_adquisicion, SUM(gasto) AS spend 
    FROM ua_spend 
    GROUP BY canal_adquisicion
),
iap AS (
    SELECT u.canal_adquisicion, SUM(p.importe::NUMERIC) * 0.70 AS net 
    FROM purchases p 
    JOIN users u ON p.user_id = u.user_id 
    GROUP BY u.canal_adquisicion
), 
ads AS (
    SELECT u.canal_adquisicion, SUM(a.ingreso) AS ads 
    FROM ad_revenue a 
    JOIN users u ON a.user_id = u.user_id 
    GROUP BY u.canal_adquisicion
)
SELECT 
	inst.canal_adquisicion, 
	ROUND(spend.spend::NUMERIC,2) as spend,
	ROUND(COALESCE(iap.net::NUMERIC, 0)+ COALESCE(ads.ads::NUMERIC,0),2)AS net_income,
	ROUND(COALESCE(iap.net::NUMERIC, 0) + COALESCE(ads.ads::NUMERIC, 0) - spend.spend::NUMERIC,2) AS profit
FROM inst
JOIN spend USING(canal_adquisicion)
LEFT JOIN iap USING(canal_adquisicion)
LEFT JOIN ads USING(canal_adquisicion)
WHERE spend.spend > 0
ORDER BY profit; 

-- Robustness of the finding: CoinRush split by country. Is it a general issue or specific to one country?
WITH coh AS (
    SELECT user_id, pais AS country
    FROM users
    WHERE canal_adquisicion = 'coinrush'
      AND ( DATE '2024-07-22' - fecha_instalacion) >= 7   -- mature cohort for D7
),
d7 AS (
    SELECT DISTINCT s.user_id
    FROM sessions s 
    JOIN users u ON s.user_id = u.user_id
    WHERE (s.fecha - u.fecha_instalacion) = 7   -- <- completed: D7 retention day
),
pay AS (
    SELECT DISTINCT user_id 
    FROM purchases
)
SELECT
    coh.country,
    COUNT(DISTINCT coh.user_id) AS players,
    ROUND(100.0 * COUNT(DISTINCT d7.user_id) / COUNT(DISTINCT coh.user_id), 1) AS d7_retention_pct,
    ROUND(100.0 * COUNT(DISTINCT pay.user_id) / COUNT(DISTINCT coh.user_id), 2) AS conversion_pct
FROM coh
LEFT JOIN d7  ON coh.user_id = d7.user_id
LEFT JOIN pay ON coh.user_id = pay.user_id
GROUP BY coh.country
ORDER BY players DESC;