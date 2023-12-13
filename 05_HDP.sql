###################################################################################################################################################################################################
# Otázka: 	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
#			či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
###################################################################################################################################################################################################


SELECT payroll.YEAR, payroll.payroll_med, payroll.pyroll_increase, price.price_med, price_increase, hdp.hdp, hdp.HDP_increase
FROM(
SELECT pri1.year, pri1.median_val payroll_med, round((pri1.median_val / (pri2.median_val / 100)), 2) - 100 pyroll_increase
FROM t_lucie_zackova_project_sql_primary_final pri1
JOIN t_lucie_zackova_project_sql_primary_final pri2
ON
pri1.year = pri2.YEAR + 1
WHERE pri1.TYPE = 'payroll'
AND pri2.TYPE = 'payroll'
GROUP BY pri1.year
) AS payroll
JOIN
(
SELECT pri1.year, pri1.median_val price_med, round((pri1.median_val / (pri2.median_val / 100)), 2) - 100 price_increase
FROM t_lucie_zackova_project_sql_primary_final pri1
JOIN t_lucie_zackova_project_sql_primary_final pri2
ON
pri1.year = pri2.YEAR + 1
WHERE pri1.TYPE = 'price'
AND pri2.TYPE = 'price'
GROUP BY pri1.year
) AS price ON
payroll.YEAR = price.year
JOIN

(SELECT sec1.year, round(sec1.HDP, 2) HDP, round((sec1.HDP / (sec2.HDP / 100)), 2) - 100 HDP_increase
FROM t_lucie_zackova_project_sql_secondary_final sec1
JOIN t_lucie_zackova_project_sql_secondary_final sec2
ON
sec1.YEAR = sec2.YEAR + 1
WHERE sec1.country = 'Czech Republic'
AND sec2.country = 'Czech Republic'
) AS hdp ON
payroll.YEAR = hdp.YEAR
ORDER BY payroll.YEAR;