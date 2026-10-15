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

-- D1 RETETION = PLAYERS WITH A SESSIN ON THE DAY (INSTALL + 1) / COHORT MATURE FOR D1.
WITH cohorte AS (
	-- Only players whoinstalled at least 1 day ago (already elegible for D1)
	SELECT user_id FROM users
	WHERE DATE '2024-07-22' - fecha_instalacion::DATE >=1
), 
retetion AS (
	SELECT DISTINCT s.user_id
	FROM sessions s
	JOIN users u ON s.user_id = u.user_id
	-- Day 1 is when the session falls exactly 1 day after installation
	WHERE s.fecha::DATE - u.fecha_instalacion::DATE = 1
)
SELECT 
	COUNT(DISTINCT c.user_id) AS cohorte, 
	COUNT(DISTINCT r.user_id) AS retenidos, 
	ROUND(100.0 * COUNT(r.user_id) / COUNT(c.user_id), 1) AS retetion_d1_pct 
FROM cohorte c
LEFT JOIN retetion r ON c.user_id = r.user_id





