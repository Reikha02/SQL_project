
-- Skripta pro vytvoření tabulek

-- -----------------------------------------------------------------------------------------------------------------------

-- 1. podpůrná tabulka s cenami potravin

CREATE TABLE t_michaela_project_food_prices AS
SELECT 
    cp.date_from AS price_date,                  
    cp.value AS food_price,                     
    cpc.name AS food_category_name,              
    cpc.price_unit AS price_unit                 
FROM 
    czechia_price cp
JOIN 
    czechia_price_category cpc ON cp.category_code = cpc.code
GROUP BY 
    cp.date_from, cpc.name;                     

-- -----------------------------------------------------------------------------------------------------------------------
    
-- 2. podpůrná tabulka s mzdami
   
CREATE TABLE t_michaela_project_salary AS
SELECT 
    cpay.payroll_year,                            
    AVG(cpay.value) AS avg_salary_value,         
    cpu.name AS salary_unit_name,                 
    cpib.name AS industry_branch                  
FROM 
    czechia_payroll cpay
JOIN 
    czechia_payroll_industry_branch cpib ON cpay.industry_branch_code = cpib.code
JOIN 
    czechia_payroll_unit cpu ON cpay.unit_code = cpu.code
JOIN 
    czechia_payroll_value_type cpvt ON cpay.value_type_code = cpvt.code
WHERE 
    cpay.value_type_code = 5958                   
    AND cpay.unit_code = 200                      
    AND cpay.payroll_year BETWEEN 2006 AND 2018   
GROUP BY 
    cpay.payroll_year,                            
    cpu.name,                                    
    cpib.name                                     
ORDER BY 
    cpib.name,                                  
    cpay.payroll_year;                           

-- -----------------------------------------------------------------------------------------------------------------------

-- 1. finální tabulka pro porovnání cen potravin a mezd (1. - 4. výzkumná otázka)
   
CREATE TABLE t_michaela_terelya_project_SQL_primary_final AS
SELECT 
    sal.payroll_year,                          
    sal.avg_salary_value,                      
    sal.salary_unit_name,                      
    sal.industry_branch,                      
    fp.food_category_name,                     
    AVG(fp.food_price) AS avg_food_price,      
    fp.price_unit                              
FROM 
    t_michaela_project_salary sal            
JOIN 
    t_michaela_project_food_prices fp ON sal.payroll_year = YEAR(fp.price_date)
GROUP BY 
    sal.payroll_year, sal.industry_branch, fp.food_category_name, fp.price_unit, sal.salary_unit_name
ORDER BY 
    sal.payroll_year, sal.industry_branch, fp.food_category_name;

-- -----------------------------------------------------------------------------------------------------------------------
   
-- 2. finální tabulka pro porovnání s HDP ukazatelem (5. výzkumná otázka)

CREATE TABLE t_michaela_terelya_project_SQL_secondary_final AS
SELECT 
    e.year AS year,                                  
    e.country AS country,                            
    e.GDP AS HDP,                                    
    AVG(s.avg_salary_value) AS avg_salary,           
    s.salary_unit_name,                              
    s.industry_branch,                               
    f.food_category_name,                            
    AVG(f.food_price) AS avg_food_price,             
    f.price_unit                                     
FROM 
    economies e
JOIN 
    t_michaela_project_salary s ON e.year = s.payroll_year  
JOIN 
    t_michaela_project_food_prices f ON YEAR(f.price_date) = e.year  
WHERE 
    e.GDP IS NOT NULL                           
    AND e.country = 'Czech Republic'            
    AND e.year BETWEEN 2005 AND 2018                
GROUP BY 
    e.year,                                          
    e.country,                                    
    s.salary_unit_name,                            
    s.industry_branch,                             
    f.food_category_name,                           
    f.price_unit,                                  
    e.GDP                                          
ORDER BY 
    e.year,                                          
    s.industry_branch;                           
       
