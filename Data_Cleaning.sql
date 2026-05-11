/* =========================================================
   WORLD LAYOFFS DATA CLEANING & ANALYSIS
   Project: SQL Data Cleaning & Exploratory Analysis
   Analyst: Rithika
   Tools Used: MySQL
========================================================= */


/* =========================================================
   STEP 1 — INITIAL DATA REVIEW
========================================================= */

SELECT *
FROM layoffs;

-- Data Cleaning Steps:
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Handle NULL or Blank Values
-- 4. Remove Unnecessary Columns


/* =========================================================
   STEP 2 — CREATE STAGING TABLE
========================================================= */

CREATE TABLE layoff_staging
LIKE layoffs;

SELECT *
FROM layoff_staging;

INSERT INTO layoff_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoff_staging;


/* =========================================================
   STEP 3 — IDENTIFY DUPLICATES
========================================================= */

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company,
                     location,
                     industry,
                     total_laid_off,
                     percentage_laid_off,
                     `date`,
                     stage,
                     country,
                     funds_raised_millions
    ) AS row_num
FROM layoff_staging;

WITH duplicate_cte AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company,
                         location,
                         industry,
                         total_laid_off,
                         percentage_laid_off,
                         `date`,
                         stage,
                         country,
                         funds_raised_millions
        ) AS row_num
    FROM layoff_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


/* =========================================================
   STEP 4 — REMOVE DUPLICATES
========================================================= */

CREATE TABLE layoff_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off DECIMAL(5,2),
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
);

SELECT *
FROM layoff_staging2;

INSERT INTO layoff_staging2

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company,
                     location,
                     industry,
                     total_laid_off,
                     percentage_laid_off,
                     `date`,
                     stage,
                     country,
                     funds_raised_millions
    ) AS row_num
FROM layoff_staging;

SELECT *
FROM layoff_staging2
WHERE row_num > 1;

DELETE
FROM layoff_staging2
WHERE row_num > 1;

-- Removed duplicate rows and verified the results.


/* =========================================================
   STEP 5 — STANDARDIZE DATA
========================================================= */

-- Remove extra spaces from company names

SELECT company, TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

-- Review distinct industries

SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

-- Standardize Crypto industry naming

SELECT *
FROM layoff_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Review distinct locations

SELECT DISTINCT location
FROM layoff_staging2
ORDER BY 1;

-- Review distinct companies

SELECT DISTINCT company
FROM layoff_staging2
ORDER BY 1;

-- Review distinct countries

SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;

-- Standardize country names

UPDATE layoff_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Review distinct funding stages

SELECT DISTINCT stage
FROM layoff_staging2
ORDER BY 1;

-- Convert date format

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoff_staging2;

-- Data standardization completed.


/* =========================================================
   STEP 6 — HANDLE NULL & BLANK VALUES
========================================================= */

SELECT *
FROM layoff_staging2
WHERE industry IS NULL
   OR industry = '';

-- Review specific company records

SELECT *
FROM layoff_staging2
WHERE company = 'Airbnb';

-- Identify rows where industry can be populated

SELECT *
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

SELECT *
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
ON t1.company = t2.company AND
t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Convert blank industry values to NULL

UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

-- Check rows where industry can be populated
SELECT *
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
ON t1.company = t2.company AND
t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Populate missing industry values

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Review Bally company records

SELECT *
FROM layoff_staging2
WHERE company LIKE 'Bally%';

-- Identify rows with no layoff information

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove rows with insufficient layoff data

DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove helper column

ALTER TABLE layoff_staging2
DROP COLUMN row_num;

-- Final cleaned dataset

SELECT *
FROM layoff_staging2;
