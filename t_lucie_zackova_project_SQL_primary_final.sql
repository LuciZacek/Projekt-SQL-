#################################################################
# View joins Payroll data with code lists						#
# Industry Branch, Value Type, Calculation Type				 	#
# and eliminates rows with NULL in values and in industry. 		#
# Final result accepts data of the Average Salary only			#
#################################################################

DROP VIEW IF EXISTS czechia_payroll_base;

CREATE VIEW czechia_payroll_base AS
SELECT cpib.name "name"
	, cpc.name "calculation_type"
	, cp.value "value"
	, cp.payroll_year "year"
	, cp.payroll_quarter "quarter"
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib ON
	cp.industry_branch_code = cpib.code
LEFT JOIN czechia_payroll_value_type cpvt ON
	cp.value_type_code = cpvt.code
LEFT JOIN czechia_payroll_calculation cpc ON
	cp.calculation_code = cpc.code
WHERE cp.value IS NOT NULL
AND cpvt.code = 5958
AND cpib.name IS NOT NULL
ORDER BY 
	cpib.name
	, cp.payroll_year
	, cp.payroll_quarter;


#################################################################
# View calculates median of calculation types 					#
# "fyzický" & "přepočtený" by each quarter, year, and industry	#												
#################################################################

DROP VIEW IF EXISTS czechia_payroll_average_by_quarter;

CREATE VIEW czechia_payroll_average_by_quarter AS
SELECT name, YEAR, quarter, avg(value) AS median_val
FROM(
	SELECT name, value, YEAR, quarter, ROW_NUMBER() OVER(PARTITION BY name, YEAR, quarter
ORDER BY
		value) rn, COUNT(*) OVER(PARTITION BY name, YEAR, quarter) cnt
FROM czechia_payroll_base
) AS dd
WHERE rn IN ( FLOOR((cnt + 1) / 2), FLOOR( (cnt + 2) / 2) )
GROUP BY
	name, YEAR, quarter;


#################################################################
# View calculates median for each year, and industry			#												
#################################################################

DROP VIEW IF EXISTS czechia_payroll_average_by_year;

CREATE VIEW czechia_payroll_average_by_year AS
SELECT name
    , YEAR
    , AVG(value) AS median_val
    , NULL "price_value"
    , NULL "price_unit"
FROM(
	SELECT name
    , value
    , YEAR
    , ROW_NUMBER() OVER(PARTITION BY name, YEAR
ORDER BY
		value) rn
    , COUNT(*) OVER(PARTITION BY name, YEAR) cnt
FROM czechia_payroll_base
) AS dd
WHERE rn IN ( FLOOR((cnt + 1) / 2), FLOOR( (cnt + 2) / 2) )
GROUP BY
	name, YEAR;


#################################################################
# View joins prices data with code list Category, 				#	
# and extracts year from timestamp.								#
#################################################################

DROP VIEW IF EXISTS czechia_price_base;

CREATE VIEW czechia_price_base AS
SELECT cpc.name "name"
	, YEAR(cp.date_from) "year"
	, value "value"
	, cpc.price_value "price_value"
	, cpc.price_unit "price_unit"
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc ON
	cpc.code = cp.category_code
WHERE cpc.name IS NOT NULL
AND cp.date_from IS NOT NULL
AND value IS NOT NULL
ORDER BY 
	cpc.name;


#################################################################
# View calculates price median for each year, product			#												
#################################################################

DROP VIEW IF EXISTS czechia_price_average_by_year;

CREATE VIEW czechia_price_average_by_year AS
SELECT name
    , YEAR
    , ROUND(AVG(value), 2) AS median_val
    , price_value
    , price_unit
FROM(
	SELECT name
    , value
    , YEAR
    , price_value
    , price_unit
    , ROW_NUMBER() OVER(PARTITION BY name, YEAR
ORDER BY
		value) rn
    , COUNT(*) OVER(PARTITION BY name, YEAR) cnt
FROM czechia_price_base cpb 
) AS dd
WHERE rn IN ( FLOOR((cnt + 1) / 2), FLOOR( (cnt + 2) / 2) )
GROUP BY
	name, YEAR;


#################################################################
# Creates final table by concatinating views					#												
# czechia_payroll_average_by_year and							#
# czechia_price_average_by_year									#
#################################################################

DROP TABLE IF EXISTS t_lucie_zackova_project_SQL_primary_final;

CREATE TABLE t_lucie_zackova_project_SQL_primary_final	
AS
SELECT cpaby.*
	, "payroll" AS "type"
FROM czechia_payroll_average_by_year cpaby
WHERE cpaby.year IN (
	SELECT DISTINCT YEAR
FROM czechia_price_average_by_year)
UNION ALL
SELECT cpaby2.*
	, "price" AS "type"
FROM czechia_price_average_by_year cpaby2;


#################################################################
# Pridani ID (Auto Increment) do finalni tabulky				#												#
#################################################################

ALTER TABLE `t_lucie_zackova_project_SQL_primary_final` ADD COLUMN `id` INT AUTO_INCREMENT UNIQUE FIRST;