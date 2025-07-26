# 🧹 MySQL Data Cleaning Project
This repository houses a comprehensive data cleaning project focused on transforming raw, messy datasets into clean, usable formats using MySQL.

# ✨ Project Goal
The primary objective of this project is to demonstrate robust data cleaning techniques within a MySQL environment, ensuring data integrity, consistency, and readiness for analysis or further application.

# 🛠️ Technologies Used
MySQL: For all data manipulation, querying, and cleaning operations.

SQL Workbench/CLI: For executing SQL scripts and interacting with the database.

# 🚀 Getting Started

Import the initial dataset: - <a href="https://github.com/AritroPaul23/SQL_Data_Cleaning_Project/blob/main/layoffs.csv">Dataset</a>

Execute cleaning scripts: Navigate to the sql/ directory and run the cleaning scripts in the specified order (if applicable).

# 🗃️ Data Cleaning Steps (Example)
## Handling Missing Values: Identification and imputation/removal of NULL or empty entries.

```sql
-- Let's change percentage_laid_off to Integer

SELECT percentage_laid_off, LEFT(percentage_laid_off, LENGTH(percentage_laid_off)-1)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET percentage_laid_off = CASE
							WHEN percentage_laid_off = '' THEN NULL
                            ELSE CAST( LEFT(percentage_laid_off, LENGTH(percentage_laid_off)-1) AS UNSIGNED ) END;
                            
ALTER TABLE layoffs_staging3
MODIFY COLUMN percentage_laid_off INTEGER;

SELECT * FROM layoffs_staging3;
```

## Duplicate Removal: Eliminating redundant records.

```sql
/* Now we are going to make a lot changes in the raw data so if we make some mistake in the process we should have the raw data to go back.
So we will create another table with the same column, structure and record like layoffs*/


CREATE TABLE layoffs_staging   -- Table Creation: MySQL create a new table named layoffs_staging
SELECT * FROM layoffs          -- Schema Copying: The new layoffs_staging table will inherit the same column names and data types as the layoffs table. It essentially clones the structure of layoffs.
WHERE 1 = 1;                   -- Data Copying: All rows from the layoffs table will be copied into the newly created layoffs_staging table. The WHERE 1=1 clause is a condition that is always true.

SELECT *
FROM layoffs_staging;

-- 1. Remove Duplicates

SELECT *,
ROW_NUMBER() OVER ( PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised_in_millions, country ) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER ( PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised_in_millions, country ) AS row_num
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;  -- Duplicate Rows

SELECT * FROM layoffs_staging
WHERE company =  'Beyond Meat'; -- Checking the duplicate entries

SELECT * FROM layoffs_staging
WHERE company =  'Cazoo'; -- Checking the duplicate entries

/* Now have to delete only duplicate rows where row_num > 1
Creating another table named layoffs_staging2*/

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised_in_millions` text,
  `country` text,
  `date_added` text,
  `row_num` INT -- Including row_num as a field datatype integer
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2 -- Inserting all the records of layoffs_staging including row_num
SELECT *,
ROW_NUMBER() OVER ( PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised_in_millions, country ) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2;  -- Till here total 4114 rows in this table

Set SQL_SAFE_UPDATEs = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;   -- Now deleting all the records of the rows whose row_num > 1

SELECT * FROM layoffs_staging2; -- After deleting total 4112 rows, 2 duplicate rows are deleted.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;            -- Dropping the column row_num as we don't need it anymore.

SELECT * FROM layoffs_staging2;

```

## Data Type Correction: Ensuring columns have appropriate data types.

```sql
/* This is imp. we need to change date columns datatype from text to date datatype*/

CREATE TABLE layoffs_staging3
SELECT * FROM layoffs_staging2
WHERE 1=1;  -- Creating another table to have a back up if i messed it up

SELECT DISTINCT stage
FROM layoffs_staging3
ORDER BY 1 ASC;  -- Checking if it matching with last process of standardization

SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y'), STR_TO_DATE(`date`,'%m-%d-%Y')
FROM layoffs_staging3;

/* We have to make all the dates in same format */

SELECT `date`, STR_TO_DATE(REPLACE(`date`,'-','/'), '%m/%d/%Y')
FROM layoffs_staging3;

-- Applying 1st format change

UPDATE layoffs_staging3
SET `date` = STR_TO_DATE(REPLACE(`date`,'-','/'), '%m/%d/%Y');

SELECT * FROM layoffs_staging3;

-- Still in this table the `date` field is in text datatype we have to change it for further calculations

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` date; -- Now it is done

-- same thing with date_added

SELECT date_added, STR_TO_DATE(REPLACE(date_added,'-','/'), '%m/%d/%Y')
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET date_added = STR_TO_DATE(REPLACE(date_added,'-','/'), '%m/%d/%Y');

ALTER TABLE layoffs_staging3
MODIFY COLUMN date_added date;

SELECT * FROM layoffs_staging3;

-- Let's change funds_raised_in_millions from text to integer

SELECT funds_raised_in_millions, RIGHT(funds_raised_in_millions, LENGTH(funds_raised_in_millions)-1)
FROM layoffs_staging3; -- Omitting the $ sign

UPDATE layoffs_staging3
SET funds_raised_in_millions = RIGHT(funds_raised_in_millions, LENGTH(funds_raised_in_millions)-1); -- Updating the records without $ in the table

SELECT * FROM layoffs_staging3;

UPDATE layoffs_staging3
SET funds_raised_in_millions = NULL
WHERE funds_raised_in_millions = ''; -- Inserting NULL records in the place of blank records

ALTER TABLE layoffs_staging3
MODIFY COLUMN funds_raised_in_millions INTEGER; -- Now changing the datatype to text to INTEGER
```

## Standardization & Formatting: Unifying inconsistent data entries (e.g., date formats, text casing).

```sql
-- Standardizing data ( Finding issues in your data and fixing it )
-- If you have some extra spaces in your records of any column you have to clean it.

SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); -- Removing the extr spaces from the recods company and updating the new records without extraspaces in the same column.

SELECT * FROM layoffs_staging2;

-- Let's look at the industry now

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1 ASC;  -- 1 company with blank industry

SELECT *
FROM layoffs_staging2
WHERE industry = ''; -- Company name is Appsmith where industry = blank / ''

UPDATE layoffs_staging2
SET industry = 'Product'
WHERE industry = ''; -- Updating industry = 'Product' where industry = '' ( Seached in google company like Appsmith, the companies showing in google are also in this table their industry is showing as product )

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1 ASC;    -- Prevoiusly Distinct company count was 31 now 30, let's check further.

SELECT * FROM layoffs_staging2
WHERE company = 'Appsmith';  -- Now industry showing as product
```

## Outlier Detection & Treatment: Identifying and addressing unusual data points.

# 📊 Cleaned Data
The cleaned_file: <a href="https://github.com/AritroPaul23/SQL_Data_Cleaning_Project/blob/main/layoffs_cleaned.csv">layoffs_cleaned</a>


# 🤝 Contributions
Feel free to open issues or submit pull requests if you have suggestions or improvements!
