DROP TABLE IF EXISTS t_lucie_zackova_project_SQL_secondary_final;
CREATE TABLE t_lucie_zackova_project_SQL_secondary_final
AS
SELECT country
	, YEAR
	, gdp / population "HDP"
FROM economies
WHERE GDP IS NOT NULL
AND population IS NOT NULL
AND YEAR IN (SELECT DISTINCT YEAR
FROM t_lucie_zackova_project_sql_primary_final);