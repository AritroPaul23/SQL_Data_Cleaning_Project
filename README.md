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

## Standardization & Formatting: Unifying inconsistent data entries (e.g., date formats, text casing).

## Outlier Detection & Treatment: Identifying and addressing unusual data points.

# 📊 Cleaned Data
The cleaned_data/ directory (or a designated database schema/table) will contain the final, processed dataset ready for use.

# 🤝 Contributions
Feel free to open issues or submit pull requests if you have suggestions or improvements!
