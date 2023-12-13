###################################################################################################################################################################################################
# Otázka 4: 	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
###################################################################################################################################################################################################

SELECT perc_price.year, perc_price.perc_price, perc_payroll.perc_payroll, CASE 
			WHEN (perc_price.perc_price - perc_payroll.perc_payroll) > 10 THEN "1"
ELSE "0"
	END AS price_increase
FROM(
	SELECT f1.year
	, f1.median_val median_price
	, f2.median_val previous_year_median_price
	, round((f1.median_val / (f2.median_val / 100)), 2) - 100 perc_price
FROM t_lucie_zackova_project_sql_primary_final f1
INNER JOIN 
	t_lucie_zackova_project_sql_primary_final f2
ON
			f1.year = f2.year + 1
WHERE f1.type = 'price'
AND f2.type = 'price'
GROUP BY
			f1.YEAR
) AS perc_price
JOIN (
	SELECT f1.year
	, f1.median_val median_payroll
	, f2.median_val previous_year_median_payroll
	, round((f1.median_val / (f2.median_val / 100)), 2) - 100 perc_payroll
FROM t_lucie_zackova_project_sql_primary_final f1
INNER JOIN 
	t_lucie_zackova_project_sql_primary_final f2
ON
				f1.year = f2.year + 1
WHERE f1.type = "payroll"
AND f2.type = "payroll"
GROUP BY
				f1.year
) AS perc_payroll
ON
	perc_price.YEAR = perc_payroll.YEAR;