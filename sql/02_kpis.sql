-- Payer conversion 
SELECT 
	(SELECT COUNT(*) FROM users) AS players,
	COUNT(DISTINCT user_id) AS pagadores, 
	ROUND(100.0 * COUNT(DISTINCT user_id)
		/(SELECT COUNT(*) FROM users),2) AS convertion_pct
FROM purchases;