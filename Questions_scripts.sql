
-- Skripta pro zodpovězení výzkumných otázek

-- -----------------------------------------------------------------------------------------------------------------------
  


-- 1. výzkumná otázka "Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?"

-- Tabulka zobrazující pouze ty roky a odvětví, kdy docházelo k poklesu průměrné mzdy. 
   
WITH salary_trends AS (
    SELECT 
        payroll_year,
        industry_branch,
        AVG(avg_salary_value) AS avg_salary_value,          
        LAG(AVG(avg_salary_value)) OVER (PARTITION BY industry_branch ORDER BY payroll_year) AS prev_salary_value,
        CASE
            WHEN AVG(avg_salary_value) > LAG(AVG(avg_salary_value)) OVER (PARTITION BY industry_branch ORDER BY payroll_year) THEN 'Rising'
            WHEN AVG(avg_salary_value) < LAG(AVG(avg_salary_value)) OVER (PARTITION BY industry_branch ORDER BY payroll_year) THEN 'Falling'
            ELSE 'Stagnation'
        END AS salary_trend
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        payroll_year, 
        industry_branch
)
SELECT 
    payroll_year,
    industry_branch,
    avg_salary_value,
    prev_salary_value,
    salary_trend,
    CASE
        WHEN prev_salary_value IS NOT NULL THEN
            ROUND(((avg_salary_value - prev_salary_value) / prev_salary_value) * 100, 2)  
        ELSE
            NULL  
    END AS percent_change
FROM 
    salary_trends
WHERE 
    salary_trend = 'Falling'  
ORDER BY 
    payroll_year, 
    industry_branch;

-- Doplňková tabulka zobrazující celkový průběh růstu, stagnace a poklesu mezd v průběhu let. 
   
SELECT 
    industry_branch,
    payroll_year,
    avg_salary_value,
    LAG(avg_salary_value) OVER (PARTITION BY industry_branch ORDER BY payroll_year) AS prev_salary_value,
    CASE
        WHEN avg_salary_value > LAG(avg_salary_value) OVER (PARTITION BY industry_branch ORDER BY payroll_year) THEN 'Rising'
        WHEN avg_salary_value < LAG(avg_salary_value) OVER (PARTITION BY industry_branch ORDER BY payroll_year) THEN 'Falling'
        ELSE 'Stagnation'
    END AS salary_trend
FROM 
    t_michaela_terelya_project_SQL_primary_final
GROUP BY 
    payroll_year, 
    industry_branch
ORDER BY 
    industry_branch, 
    payroll_year;

   
   
-- -----------------------------------------------------------------------------------------------------------------------

-- 2. výzkumná otázka "Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období 
-- v dostupných datech cen a mezd?"

-- Skript pro chleba 
   
WITH first_and_last_year AS (
    SELECT 
        MIN(payroll_year) AS first_year,
        MAX(payroll_year) AS last_year
    FROM 
        t_michaela_terelya_project_SQL_primary_final
),
selected_data AS (
    SELECT 
        payroll_year,
        AVG(avg_salary_value) AS avg_salary,  
        AVG(CASE WHEN food_category_name LIKE '%chléb%' THEN avg_food_price END) AS avg_bread_price, 
        MAX(CASE WHEN food_category_name LIKE '%chléb%' THEN price_unit END) AS price_unit 
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    WHERE 
        payroll_year IN (SELECT first_year FROM first_and_last_year
                         UNION
                         SELECT last_year FROM first_and_last_year)
    GROUP BY 
        payroll_year
)
SELECT 
    payroll_year,
    avg_salary,
    avg_bread_price,
    ROUND(avg_salary / avg_bread_price) AS amount_of_bread,
    price_unit
FROM 
    selected_data
WHERE 
    avg_bread_price IS NOT NULL  
ORDER BY 
    payroll_year;

   
   
-- Skript pro mléko

WITH first_and_last_year AS (
    SELECT 
        MIN(payroll_year) AS first_year,
        MAX(payroll_year) AS last_year
    FROM 
        t_michaela_terelya_project_SQL_primary_final
),
selected_data AS (
    SELECT 
        payroll_year,
        AVG(avg_salary_value) AS avg_salary, 
        AVG(CASE WHEN food_category_name LIKE '%mléko%' THEN avg_food_price END) AS avg_milk_price,  
        MAX(CASE WHEN food_category_name LIKE '%mléko%' THEN price_unit END) AS price_unit  
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    WHERE 
        payroll_year IN (SELECT first_year FROM first_and_last_year
                         UNION
                         SELECT last_year FROM first_and_last_year)
    GROUP BY 
        payroll_year
)
SELECT 
    payroll_year,
    avg_salary,
    avg_milk_price,
    ROUND(avg_salary / avg_milk_price) AS amount_of_milk,
    price_unit
FROM 
    selected_data
WHERE 
    avg_milk_price IS NOT NULL  
ORDER BY 
    payroll_year;
   
-- -----------------------------------------------------------------------------------------------------------------------

   
   
-- 3. výzkumná otázka "Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)"
   
-- Skript pro zjištění jaká kategorie potravin zdražuje nejpomaleji
   
WITH yearly_price_change AS (
    SELECT 
        food_category_name,
        payroll_year,
        AVG(CAST(avg_food_price AS DECIMAL(10, 2))) AS avg_food_price  
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        food_category_name, payroll_year  
),
price_increase AS (
    SELECT 
        food_category_name,
        payroll_year,
        avg_food_price,
        LAG(avg_food_price) OVER (PARTITION BY food_category_name ORDER BY payroll_year) AS previous_price,
        ((avg_food_price - LAG(avg_food_price) OVER (PARTITION BY food_category_name ORDER BY payroll_year)) / 
        LAG(avg_food_price) OVER (PARTITION BY food_category_name ORDER BY payroll_year)) * 100 AS percentage_increase
    FROM 
        yearly_price_change
)
SELECT 
    food_category_name,
    AVG(percentage_increase) AS average_percentage_increase
FROM 
    price_increase
WHERE 
    previous_price IS NOT NULL
GROUP BY 
    food_category_name
ORDER BY 
    average_percentage_increase ASC
LIMIT 1;



-- Doplňkový skript pro kontrolu konkrétních změn u cen cukru mezi jednotlivými roky.

WITH price_changes AS (
    SELECT 
        food_category_name,
        payroll_year AS price_year,
        AVG(CAST(avg_food_price AS DECIMAL(10, 2))) AS avg_food_price  
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    WHERE 
        food_category_name = 'Cukr krystalový'
    GROUP BY 
        price_year
),
price_changes_with_lag AS (
    SELECT 
        food_category_name,
        price_year,
        avg_food_price,
        LAG(avg_food_price) OVER (PARTITION BY food_category_name ORDER BY price_year) AS previous_year_price
    FROM 
        price_changes
)
SELECT 
    food_category_name,
    price_year,
    avg_food_price,
    previous_year_price,
    ROUND(((avg_food_price - previous_year_price) / previous_year_price) * 100, 2) AS percentage_change
FROM 
    price_changes_with_lag
WHERE 
    previous_year_price IS NOT NULL  
ORDER BY 
    price_year;

-- -----------------------------------------------------------------------------------------------------------------------
   
   
   
-- 4. výzkumná otázka "Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?" 

WITH food_price_changes AS (
    SELECT 
        payroll_year,
        AVG(avg_food_price) AS avg_food_price,
        LAG(AVG(avg_food_price)) OVER (ORDER BY payroll_year) AS previous_year_price
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        payroll_year
),
salary_changes AS (
    SELECT 
        payroll_year,
        AVG(avg_salary_value) AS avg_salary,
        LAG(AVG(avg_salary_value)) OVER (ORDER BY payroll_year) AS previous_year_salary
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        payroll_year
),
percentage_changes AS (
    SELECT 
        f.payroll_year,
        ROUND(((f.avg_food_price - f.previous_year_price) / f.previous_year_price) * 100, 2) AS food_percentage_change,
        ROUND(((s.avg_salary - s.previous_year_salary) / s.previous_year_salary) * 100, 2) AS salary_percentage_change
    FROM 
        food_price_changes f
    JOIN 
        salary_changes s ON f.payroll_year = s.payroll_year
    WHERE 
        f.previous_year_price IS NOT NULL AND s.previous_year_salary IS NOT NULL
)
SELECT 
    payroll_year AS studied_year,
    food_percentage_change,
    salary_percentage_change
FROM 
    percentage_changes
WHERE 
    food_percentage_change > salary_percentage_change + 10 
ORDER BY 
    payroll_year;  

   
   
-- Doplňkový skript pro porovnání meziročního nárůstu cen potravin a mezd
   
WITH food_price_changes AS (
    SELECT 
        payroll_year,
        AVG(DISTINCT avg_food_price) AS avg_food_price,  
        LAG(AVG(DISTINCT avg_food_price)) OVER (ORDER BY payroll_year) AS previous_year_price
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        payroll_year
),
salary_changes AS (
    SELECT 
        payroll_year,
        AVG(DISTINCT avg_salary_value) AS avg_salary,  
        LAG(AVG(DISTINCT avg_salary_value)) OVER (ORDER BY payroll_year) AS previous_year_salary
    FROM 
        t_michaela_terelya_project_SQL_primary_final
    GROUP BY 
        payroll_year
),
percentage_changes AS (
    SELECT 
        f.payroll_year,
        ROUND(((f.avg_food_price - f.previous_year_price) / f.previous_year_price) * 100, 2) AS food_percentage_change,
        ROUND(((s.avg_salary - s.previous_year_salary) / s.previous_year_salary) * 100, 2) AS salary_percentage_change
    FROM 
        food_price_changes f
    JOIN 
        salary_changes s ON f.payroll_year = s.payroll_year
    WHERE 
        f.previous_year_price IS NOT NULL AND s.previous_year_salary IS NOT NULL
)
SELECT 
    payroll_year AS studied_year,
    food_percentage_change,
    salary_percentage_change,
    ROUND(food_percentage_change - salary_percentage_change, 2) AS percentage_difference 
FROM 
    percentage_changes
ORDER BY 
    payroll_year;  
  

   
-- -----------------------------------------------------------------------------------------------------------------------
   
-- 5. výzkumná otázka "Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji 
-- v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?"
                          
WITH yearly_avg_data AS (
    SELECT 
        year,
        AVG(DISTINCT avg_salary) AS avg_yearly_salary,      
        AVG(DISTINCT avg_food_price) AS avg_yearly_food_price 
    FROM 
        t_michaela_terelya_project_SQL_secondary_final
    GROUP BY 
        year
),
gdp_growth AS (
    SELECT 
        year,
        ((HDP - LAG(HDP) OVER (ORDER BY year)) / LAG(HDP) OVER (ORDER BY year)) * 100 AS gdp_growth_pct
    FROM 
        (SELECT DISTINCT year, HDP FROM t_michaela_terelya_project_SQL_secondary_final) AS distinct_gdp_data
),
growth_data AS (
    SELECT 
        year,
        ((avg_yearly_salary - LAG(avg_yearly_salary) OVER (ORDER BY year)) / LAG(avg_yearly_salary) OVER (ORDER BY year)) * 100 AS salary_growth_pct,
        ((avg_yearly_food_price - LAG(avg_yearly_food_price) OVER (ORDER BY year)) / LAG(avg_yearly_food_price) OVER (ORDER BY year)) * 100 AS food_price_growth_pct
    FROM 
        yearly_avg_data
)
SELECT 
    g.year,                                
    ROUND(gd.salary_growth_pct, 2) AS avg_salary_growth_pct,   
    ROUND(gd.food_price_growth_pct, 2) AS avg_food_price_growth_pct, 
    ROUND(g.gdp_growth_pct, 2) AS gdp_growth_pct  
FROM 
    growth_data gd
JOIN 
    gdp_growth g ON gd.year = g.year      
WHERE 
    g.gdp_growth_pct IS NOT NULL          

ORDER BY 
    g.year;
    
-- -----------------------------------------------------------------------------------------------------------------------
 