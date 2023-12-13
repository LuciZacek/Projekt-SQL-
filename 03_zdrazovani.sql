###################################################################################################################################################################################################
# Otázka 3: 	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
###################################################################################################################################################################################################


SELECT perc.name, round(avg(perc.percentile), 2) perc_av
FROM(
	SELECT f1.name
	, f1.year
	, f1.median_val
	, f2.median_val previous_year_median
	, round((f1.median_val / (f2.median_val / 100)), 2) - 100 percentile
FROM t_lucie_zackova_project_sql_primary_final f1
INNER JOIN 
	t_lucie_zackova_project_sql_primary_final f2
ON
		f1.year = f2.year + 1
AND f1.name = f2.name
WHERE f1.type = 'price'
) AS perc
GROUP BY
	name
ORDER BY
	round(avg(perc.percentile), 2);