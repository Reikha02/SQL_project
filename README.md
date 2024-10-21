# Analýza vývoje mezd a cen v ČR pomocí SQL

## Úvod
Tento projekt se zaměřuje na analýzu vývoje mezd a cen potravin v České republice pomocí SQL. Hlavním cílem je zodpovědět několik výzkumných otázek týkajících se růstu mezd a cen v různých obdobích, a zjistit, jaký vliv mají ekonomické ukazatele jako HDP na tyto trendy. 

K analýze byla využita datová sada obsahující historické ceny potravin a mzdové údaje, které byly analyzovány pomocí SQL dotazů. Projekt zahrnuje tvorbu a údržbu několika tabulek a skriptů k zodpovězení těchto výzkumných otázek.

## Postup vytvoření a použití skriptů

### Krok 1: Vytvoření podpůrných tabulek
Pro úspěšnou analýzu je nejprve třeba vytvořit dvě podpůrné tabulky, které obsahují základní data o cenách potravin a mzdách:

- **t_michaela_project_food_prices** – obsahuje historické ceny potravin.
- **t_michaela_project_salary** – obsahuje údaje o vývoji mezd.

Skripta pro vytvoření těchto tabulek jsou zahrnuta v souboru `Tabs_scripts.sql`.

### Krok 2: Vytvoření hlavních tabulek
Po vytvoření podpůrných tabulek následuje tvorba dvou hlavních tabulek, ve kterých jsou data připravena pro detailnější analýzu:

- **t_michaela_terelya_project_SQL_primary_final** – obsahuje zpracovaná data s kombinací informací o cenách potravin a mzdách.
- **t_michaela_terelya_project_SQL_secondary_final** – obsahuje další výpočty a analýzy pro zodpovězení výzkumných otázek.

Skripta pro vytvoření těchto hlavních tabulek jsou také dostupná v souboru `Tabs_scripts.sql`.

### Krok 3: Odstranění podpůrných tabulek
Po dokončení analýzy doporučujeme podpůrné tabulky odstranit, aby nepřekážely v databázi.
```bash
   DROP TABLE t_michaela_project_food_prices, t_michaela_project_salary;


