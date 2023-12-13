###################################################################################################################################################################################################
# Otázka 2: 	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
###################################################################################################################################################################################################

SELECT name, year, ROUND((SELECT ROUND(AVG(median_val), 2) 
FROM t_lucie_zackova_project_sql_primary_final
WHERE YEAR = (SELECT min(YEAR) FROM t_lucie_zackova_project_sql_primary_final) AND TYPE = "payroll") / first_period.median_val) purchasing_power
FROM(
	SELECT name, YEAR, median_val, TYPE
FROM t_lucie_zackova_project_sql_primary_final) AS first_period
WHERE first_period.year = (
	SELECT min(YEAR)
FROM t_lucie_zackova_project_sql_primary_final
WHERE(first_period.name = name
	AND first_period.name = "Mléko polotučné pasterované")
OR (first_period.name = name
	AND first_period.name = "Chléb konzumní kmínový")
GROUP BY
		name )
AND first_period.type = "price";

###################################################################################################################################################################################################

SELECT
	name,
	YEAR,
	ROUND((SELECT ROUND(AVG(median_val), 2) 
FROM t_lucie_zackova_project_sql_primary_final
WHERE YEAR = (SELECT max(YEAR) FROM t_lucie_zackova_project_sql_primary_final) AND TYPE = "payroll") / last_period.median_val) purchasing_power
FROM
	(
	SELECT
		name,
		YEAR,
		median_val,
		TYPE
	FROM
		t_lucie_zackova_project_sql_primary_final) AS last_period
WHERE
	last_period.year = (
	SELECT
		max(YEAR)
	FROM
		t_lucie_zackova_project_sql_primary_final
	WHERE
		(last_period.name = name
			AND last_period.name = "Mléko polotučné pasterované")
		OR (last_period.name = name
			AND last_period.name = "Chléb konzumní kmínový")
	GROUP BY
		name )
	AND last_period.type = "price";
