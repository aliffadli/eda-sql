-- Average revenue per employee for Fortune 500 companies by sector.
SELECT sector, 
AVG(revenues/employees::numeric) AS avg_rev_employee
FROM fortune500
GROUP BY sector 
ORDER BY avg_rev_employee;


-- What is the definition of unanswered_pct column on Stack Overflow? 
-- Is it the percent of questions with the tag that are unanswered?
-- Or the percent of all unanswered questions on the site with the tag?
-- The following query will answered the above question
-- Divide unanswered_count column by question_count column 
-- to see if the value matches that of unanswered_pct to determine the answer
SELECT unanswered_count/question_count::numeric AS computed_pct,
unanswered_pct 
FROM stackoverflow
-- Exclude rows where question_count is 0 to avoid a divide by zero error.
WHERE question_count != 0
LIMIT 10;
-- RESULT: The values don't match. 
-- unanswered_pct is the percent of unanswered questions on Stack Overflow with the tag, 
-- not the percent of questions with the tag that are unanswered.



-- Select min, avg, max, and stddev of fortune500 profits
SELECT min(profits),
       avg(profits),
       max(profits),
       stddev(profits)
  FROM fortune500;
  
-- Select sector and summary measures of fortune500 profits
SELECT sector,
       MIN(profits),
       AVG(profits),
       MAX(profits),
       STDDEV(profits)
  FROM fortune500
 GROUP BY sector
 ORDER BY avg;

-- find standard deviation, minimum, maximum, average value
-- across tags in the maximum number of Stack Overflow questions per day
SELECT STDDEV(maxval),
	   -- min
       MIN(maxval),
       -- max
       MAX(maxval),
       -- avg
       AVG(maxval)
  -- Subquery to compute max of question_count by tag
  FROM (SELECT MAX(question_count) AS maxval
          FROM stackoverflow
         GROUP BY tag) AS max_results; -- alias for subquery


-- examine the distributions of attributes of the Fortune 500 companies
SELECT trunc(employees, -5) AS employee_bin,
COUNT(*)
FROM fortune500
GROUP BY employee_bin 
ORDER BY employee_bin;


-- examine the distributions of attributes 
-- with company that have < 100,000 employee (most common)
SELECT trunc(employees, -4) AS employee_bin,
COUNT(*)
FROM fortune500
WHERE employees < 100000
GROUP BY employee_bin
ORDER BY employee_bin;

-- Compute correlation 
-- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;


-- Compute the mean (avg()) and median assets of Fortune 500 companies by sector
SELECT sector, 
AVG(assets) AS mean, 
percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median 
FROM fortune500
GROUP BY sector
ORDER BY mean;


-- Find the Fortune 500 companies that have profits in the top 20% 
-- for their sector (compared to other Fortune 500 companies)
DROP TABLE IF EXISTS profit80; 
-- create temporary table to store pct80 in each sector
CREATE TEMP TABLE profit80 AS 
SELECT sector, 
percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS 
pct80
FROM fortune500
GROUP BY sector; 
-- the main query 
SELECT title, fortune500.sector, 
profits, profits/pct80 AS ratio
FROM fortune500 
LEFT JOIN profit80 
ON fortune500.sector=profit80.sector 
WHERE fortune500.profits > pct80;


-- Find how many questions had each tag on the first date for which data for the tag is available, 
-- as well as how many questions had the tag on the last day
-- Then, compute the difference between these two values.

-- Note: The Stack Overflow data contains daily question counts through 2018-09-25 for all tags, 
-- but each tag has a different starting date in the data.

DROP TABLE IF EXISTS startdates; 

-- find the minimal date for each tag 
CREATE TEMP TABLE startdates AS 
SELECT tag, MIN(date) AS mindate
FROM stackoverflow 
GROUP BY tag;

SELECT startdates.tag, 
mindate, so_min.question_count AS min_date_question_count, 
so_max.question_count AS max_date_question_count, 
so_max.question_count - so_min.question_count AS change 
FROM startdates
INNER JOIN stackoverflow AS so_min 
ON startdates.tag=so_min.tag 
AND startdates.mindate=so_min.date
INNER JOIN stackoverflow AS so_max 
ON startdates.tag=so_max.tag
AND so_max.date='2018-09-25';


-- create a correlation table using temporary table 
DROP TABLE IF EXISTS correlations; 

CREATE TEMP TABLE correlations AS 
SELECT 'profits'::varchar AS measure, 
corr(profits, profits) AS profits, 
corr(profits, profits_change) AS profits_change, 
corr(profits, revenues_change) AS revenues_change
FROM fortune500;

-- inserting 2 other records into correlations table
INSERT INTO correlations 
SELECT 'profits_change'::varchar AS measure, 
corr(profits_change, profits) AS profits,
corr(profits_change, profits_change) AS profits_change, 
corr(profits_change, revenues_change) AS revenues_change
FROM fortune500; 

INSERT INTO correlations 
SELECT 'revenues_change'::varchar AS measure, 
corr(revenues_change, profits) AS profits, 
corr(revenues_change, profits_change) AS profits_change, 
corr(revenues_change, revenues_change) AS revenues_change
FROM fortune500; 

-- select each column and rounding the correlations 
SELECT measure, 
ROUND(profits::numeric, 2) AS profits, 
ROUND(profits_change::numeric, 2) AS profits_change, 
ROUND(revenues_change::numeric, 2) AS revenues_change
FROM correlations; 
