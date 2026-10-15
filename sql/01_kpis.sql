-- DAU = DAILY ACTIVE USERS
WITH actives_per_day AS (
	SELECT 
		fecha AS date, 
		COUNT(DISTINCT user_id) AS actives
	FROM sessions
	GROUP BY fecha
)
SELECT 
	ROUND(AVG(actives),0) avg_dau, 
	COUNT(*) AS days_with_activity
FROM actives_per_day;

-- MAU: MONTHLY ACTIVE USERS
WITH mau AS (
	SELECT COUNT(DISTINCT user_id) AS mau
	FROM sessions
	WHERE fecha > DATE '2024-07-22' - 30
), 
dau AS (
	SELECT 
		AVG(activos) AS dau
	FROM (SELECT fecha, COUNT(DISTINCT user_id) AS activos FROM sessions GROUP BY fecha)
)
SELECT
	mau.mau, 
	ROUND(dau.dau, 0) AS avg_dau, 
	ROUND(100.0 * dau.dau /mau.mau, 2) AS stickness_pct --monthly users who connect daily
FROM mau, dau; 