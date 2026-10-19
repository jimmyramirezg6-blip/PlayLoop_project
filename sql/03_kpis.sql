
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