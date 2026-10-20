


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

-- RETENTION D1 BY CHANNEL
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

-- RETETION D7 BY CHANNEL
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
ORDER BY retetion_d7_pct
