/* =========================================================
   WORLD LAYOFFS EXPLORATORY DATA ANALYSIS
   Project: SQL Data Cleaning & Exploratory Analysis
   Analyst: Rithika
   Tools Used: MySQL
========================================================= */


/* =========================================================
   STEP 7 — EXPLORATORY DATA ANALYSIS
========================================================= */

-- Maximum layoffs and layoff percentage

SELECT
    MAX(total_laid_off),
    MAX(percentage_laid_off)
FROM layoff_staging2;

-- Companies with 100% layoffs

SELECT *
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Companies with 100% layoffs by funding raised

SELECT *
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company

SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs by industry

SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country

SELECT
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by year

SELECT
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY layoff_year
ORDER BY 1 DESC;

-- Total layoffs by funding stage

SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average layoff percentage by company

SELECT
    company,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Monthly layoff trends

SELECT
    SUBSTR(`date`, 1, 7) AS `MONTH`,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling total layoffs by month

WITH Rolling_Total AS
(
    SELECT
        SUBSTR(`date`, 1, 7) AS `MONTH`,
        SUM(total_laid_off) AS sum_total_laid_off
    FROM layoff_staging2
    WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
)

SELECT
    `MONTH`,
    sum_total_laid_off,
    SUM(sum_total_laid_off)
    OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Total layoffs by company and year

SELECT
    company,
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY company, layoff_year
ORDER BY 3 DESC;

-- Top 5 companies with highest layoffs each year

WITH Company_Year (company, years, total_laid_off) AS
(
    SELECT
        company,
        YEAR(`date`),
        SUM(total_laid_off)
    FROM layoff_staging2
    GROUP BY company, YEAR(`date`)
),

Ranking_Data AS
(
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY years
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)

SELECT *
FROM Ranking_Data
WHERE ranking <= 5;


/* =========================================================
   END OF PROJECT
========================================================= */
