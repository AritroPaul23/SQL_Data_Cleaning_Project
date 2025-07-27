SELECT * FROM layoffs_staging3;

SELECT *
FROM layoffs_staging3
WHERE industry = ''
		OR
	  industry IS NULL;
      
SELECT DISTINCT industry
FROM layoffs_staging3;

SELECT t1.company, t1.industry, t2.industry, t1.`date`, t2.`date`
FROM layoffs_staging3 t1
		INNER JOIN layoffs_staging3 t2
        ON t1.company = t2.company
			AND t1.location = t2.location
WHERE t1.industry <> t2.industry;

-- These are the records for which total_laid_off AND percentage_laid_off are NULL, so we can delete these recods as for our analysis these aren't necessary.
SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
		AND percentage_laid_off IS NULL;

SET SQL_SAFE_UPDATEs = 0;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
		AND percentage_laid_off IS NULL;
        
SELECT * FROM layoffs_staging3; -- This is our final table ROW Count 3437

