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
WITH cohort AS (
	-- Only players who installed at least 1 day ago (already elegible for D1)
	SELECT user_id FROM users
	WHERE DATE '2024-07-22' - fecha_instalacion::DATE >=1
), 
retained AS (
	SELECT DISTINCT s.user_id
	FROM sessions s
	JOIN users u ON s.user_id = u.user_id
	-- Day 1 is when the session falls exactly 1 day after installation
	WHERE s.fecha::DATE - u.fecha_instalacion::DATE = 1
)
SELECT 
	COUNT(DISTINCT c.user_id) AS cohort, 
	COUNT(DISTINCT r.user_id) AS retenidos, 
	ROUND(100.0 * COUNT(r.user_id) / COUNT(c.user_id), 1) AS retetion_d1_pct 
FROM cohort c
LEFT JOIN retained r ON c.user_id = r.user_id

-- D1/D7/D30 RETETION
WITH days(n) AS (VALUES(1),(7),(30))
SELECT 
	d.n AS day, 
	COUNT(DISTINCT u.user_id) AS cohort, 
	COUNT(DISTINCT s.user_id) AS retained, 
	ROUND(100.0 * COUNT(DISTINCT s.user_id)/COUNT(DISTINCT u.user_id),1) AS retetion_pct
FROM days d
-- Cohort mature at each day:installed at least d.n days ago	
JOIN users u ON (DATE '2024-07-22' - u.fecha_instalacion) >= d.n
-- Sessions that falls exactly on the player's day d.n of life
LEFT JOIN sessions s
	ON s.user_id = u.user_id
	AND	(s.fecha::DATE - u.fecha_instalacion) = d.n
GROUP BY d.n
ORDER BY d.n;

-- D30 RETETION 
WITH d30_retained AS(
	SELECT DISTINCT s.user_id 
	FROM sessions s 
	JOIN users u ON s.user_id = u.user_id
	WHERE s.fecha::DATE - u.fecha_instalacion::DATE = 30
), 
mature_cohort AS (
	-- -- Only players who installed at least 30 days ago
	SELECT user_id FROM users
	WHERE (DATE '2024-07-22' - fecha_instalacion) >= 30
)
SELECT 
	ROUND(100.0 * (SELECT COUNT(*) FROM d30_retained) / (SELECT COUNT(*) FROM mature_cohort),1)  AS d30_correct,
	ROUND(100.0 * (SELECT COUNT(*) FROM d30_retained) / (SELECT COUNT(*) FROM users),1)  AS d30_incorrect; 





