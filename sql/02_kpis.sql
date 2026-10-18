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
