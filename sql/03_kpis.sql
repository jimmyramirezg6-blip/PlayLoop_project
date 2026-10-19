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
