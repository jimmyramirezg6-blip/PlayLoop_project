-- PAYER CONVERSION  
SELECT 
	(SELECT COUNT(*) FROM users) AS players,
	COUNT(DISTINCT user_id) AS pagadores, 
	ROUND(100.0 * COUNT(DISTINCT user_id)
		/(SELECT COUNT(*) FROM users),2) AS convertion_pct
FROM purchases;

-- GROSS INCOME AND NET INCOME
SELECT 
	ROUND(SUM(importe::NUMERIC), 2) AS bruto, 
	ROUND(SUM(importe::NUMERIC) * 0.30,2) AS store_comotion,
	ROUND(SUM(importe::NUMERIC)* 0.70, 2) AS neto
FROM purchases;

-- ARPU : AVERAGE REVENNUE PER USER
-- ARPU = (NET IAP + AD REVENUE ) ALL PLAYERS
SELECT 
	ROUND(
		((SELECT SUM(importe::NUMERIC) * 0.70 FROM purchases)
		+ (SELECT SUM(ingreso::NUMERIC) FROM ad_revenue))
		/ (SELECT COUNT(*) FROM users)
	,3) AS net_arpu;

-- BREAKDOWN OF NET INCOME BETWEEN THE TWO CHANNELS: PURCHASES (NET IAP) AND ADS
SELECT 
	ROUND((SELECT SUM(importe::NUMERIC) * 0.70 FROM purchases),2) AS net_iap, 
	ROUND((SELECT SUM(ingreso::NUMERIC) FROM ad_revenue),2) AS ad_revenue, 
	ROUND(
		100.0 * (SELECT SUM(importe::NUMERIC) * 0.70 FROM purchases) / ((SELECT SUM(importe::NUMERIC) * 0.70 FROM purchases)+ (SELECT SUM(ingreso::NUMERIC)FROM ad_revenue))
		, 2) AS net_iap_pct

-- CONCENTRATION: HOW MUCH IAP REVENUE IS CONTRIBUTED BY THE TOP 2% SPENDING PLAYERS 
WITH spend_per_players AS (
	SELECT
		user_id, 
		SUM(importe::NUMERIC) AS spend
	FROM purchases
	GROUP BY user_id
), 
ranking AS (
	SELECT 
		spend, 
		ROW_NUMBER() OVER (ORDER BY spend DESC) AS rn, 
		COUNt(*) OVER() AS total_players
	FROM spend_per_players
)
SELECT 
	CAST(CEIL(0.02 * total_players) AS INT) AS whales_top2pct, 
	ROUND(
		100.0 * SUM(spend) FILTER(WHERE rn <= CEIL(0.02 * total_players))
		/SUM(spend)
	,2) AS pct_whale_revenue
FROM ranking
GROUP BY total_players


-- CROSS INCOME BY PRODUCTS
SELECT 
	ip.tipo, 
	COUNT(*) purchases,
 	ROUND(SUM(p.importe::NUMERIC),2) AS cross_income
FROM purchases p
JOIN iap_products ip ON p.producto_id = ip.product_id
GROUP BY tipo
ORDER BY cross_income DESC;


-- PAYER CONVERSION BY PLATAFORM
WITH payer AS (
	SELECT DISTINCT user_id FROM purchases
)
SELECT 
	u.plataforma, 
	COUNT(DISTINCT u.user_id) AS players, 
	COUNT(DISTINCT p.user_id) AS payers, 
	ROUND(
		100.0 * COUNT(DISTINCT p.user_id) / COUNT(DISTINCT u.user_id)
	, 2)  AS payer_pct
FROM users u
LEFT JOIN payer p ON u.user_id = p.user_id
GROUP BY u.plataforma
ORDER BY payer_pct;


-- ARPPU : AVERAGE REVENNUE PER PAYING USER
WITH spend_per_player AS (
	SELECT
		user_id, 
		SUM(importe) AS spend
	FROM purchases
	GROUP BY user_id
)
SELECT
	ROUND(AVG(spend::NUMERIC), 2) AS avg_arppu, 
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spend::NUMERIC)) AS median_arppu, 
	ROUND(MAX(spend::NUMERIC), 2) AS max_spend
FROM spend_per_player;
