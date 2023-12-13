###################################################################################################################################################################################################
# Otázka 1: 	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
###################################################################################################################################################################################################


SELECT f1.name
	, f1.year
	, f1.median_val
	, f2.median_val previous_year_median
	, f1.median_val - f2.median_val difference
FROM t_lucie_zackova_project_sql_primary_final f1
INNER JOIN 
	t_lucie_zackova_project_sql_primary_final f2
ON
	f1.year = f2.year + 1
AND f1.name = f2.name
WHERE f1.type = 'payroll';