-- Data cleaning 

 SELECT * FROM  layoffs;
-- we have remove duplicates, standarise the data
-- first we create table with all the data same as the raw table 
CREATE TABLE layoffs_standarize 
 SELECT * FROM  layoffs ;

SELECT * FROM  layoffs_standarize ;

-- deleting duplicates

SELECT *, ROW_NUMBER() OVER ( PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, fundS_raised_millions
) AS No_of_Rows
FROM layoffs_standarize ;

WITH duplicate_cte AS
(SELECT *, 
ROW_NUMBER() OVER ( PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, fundS_raised_millions
) AS No_of_Rows
FROM layoffs_standarize
)
SELECT * FROM duplicate_cte 
WHERE No_of_Rows > 1;

-- create table with 1 moe column No_of_Rows and delete where its value is 2 

CREATE TABLE `layoffs_standarize2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `No_of_Rows`  int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_standarize2
SELECT *, 
ROW_NUMBER() OVER ( PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, fundS_raised_millions
) AS No_of_Rows
FROM layoffs_standarize ;

SELECT * FROM layoffs_standarize2;

-- Ucheck the Safe Updates option in Edit -> preferences -> SQL editor  in case delete command not works 

DELETE FROM layoffs_standarize2
WHERE No_of_Rows > 1 ;

SELECT * FROM layoffs_standarize2 ; 

-- Standarrizing data

-- triming the extra spaces present 

SELECT company, TRIM(company) from layoffs_standarize2 ;

UPDATE layoffs_standarize2
SET company = TRIM(company) ;

-- now we check distinct industries as we can group on the basis of that

SELECT DISTINCT industry FROM layoffs_standarize2
ORDER BY 1  ;

-- Here we have Crypto and Cryptocurrency, these can be categorise as one 

SELECT * FROM layoffs_standarize2
WHERE industry LIKE 'Crypto%' ;

-- we can see same company has crypto and cryptocurrency both 
-- we are making  CryptoCurrency to crypto 

UPDATE layoffs_standarize2
set industry = 'Crypto' 
where industry like  'Crypto%'  ;

SELECT DISTINCT country FROM layoffs_standarize2 
ORDER BY 1;

SELECT * FROM layoffs_standarize2 
WHERE country LIKE 'United States.' ;

-- here we 'United States' and 'United States.' we make them to 'United States'

UPDATE layoffs_standarize2
SET country = 'United States'
WHERE country LIKE 'United States%' ;

-- here date has text datatype we have to change it to date datatype 

SELECT `date` ,
STR_TO_DATE(`date`, '%m/%d/%Y') from layoffs_standarize2 ;

UPDATE layoffs_standarize2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y') ;

SELECT `date` FROM layoffs_standarize2;

ALTER TABLE layoffs_standarize2
MODIFY COLUMN `date` DATE ;

-- now we look to null and ' ' data in indutry column and try to fill it 

SELECT * FROM layoffs_standarize2 
WHERE industry IS NULL
OR industry = '' ;  

-- here we have Airbnb, Bally's Interactive, Carvana, Juul

SELECT * FROM layoffs_standarize2 
WHERE company = 'Airbnb' or company='Bally''s Interactive' or company='Carvana' or company='Juul'; 

-- from this we can fill 
-- Airbnb is Travel industry
-- Carvana is Transportation industry
-- Juul is Consumer industry

UPDATE layoffs_standarize2
SET industry = 'Travel'
WHERE industry = '' AND company = 'Airbnb' ;
UPDATE layoffs_standarize2
SET industry = 'Transportation'
WHERE industry = '' AND company = 'Carvana' ;
UPDATE layoffs_standarize2
SET industry = 'Consumer'
WHERE industry = '' AND company = 'Juul' ;

-- we can also do it using joins
-- now only Bally's Interactive is left with null value 

SELECT * FROM layoffs_standarize2
WHERE company LIKE 'Bally%' ;

-- lets look on total_laid_off and percentage_laid_off where they both null

SELECT * FROM layoffs_standarize2 
WHERE total_laid_off IS NULL AND 
percentage_laid_off IS NULL ;

-- As we are working on layoff data in my opinion we cant use above data as total_laid_off and percentage_laid_off where both null 
-- so removing them must be a good option 

DELETE
FROM layoffs_standarize2 
WHERE total_laid_off IS NULL AND 
percentage_laid_off IS NULL ;

-- Now last thing left is to delete the No_of_Rows column

ALTER TABLE layoffs_standarize2
DROP COLUMN No_of_Rows;

-- Now our raw data is cleaned 
SELECT * FROM layoffs_standarize2;


