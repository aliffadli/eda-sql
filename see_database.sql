-- MISSING VALUE 

-- find the missing values for ticker, profits_change, industry column
-- in fortune500 table 

SELECT COUNT(*) - COUNT(ticker) AS missing
FROM fortune500;

SELECT COUNT(*) - COUNT(profits_change) AS missing
FROM fortune500;

SELECT COUNT(*) - COUNT(industry) AS missing
FROM fortune500;


-- JOINING TABLE 

-- fortune500 and company table are in relationship in ERD 

-- Find a column in company and fortune500
-- where the values for each company are the same in both tables

SELECT company.name 
FROM company 
INNER JOIN fortune500
ON company.ticker=fortune500.ticker;


-- count the number of tag in each type 

SELECT type, COUNT(*) AS count
FROM tag_type 
GROUP BY type 
ORDER BY COUNT(*) DESC;


-- find the name of the company and tag name with the most common tag_type 

SELECT company.name, tag_type.tag, tag_type.type
FROM company 
-- joining tag_company first, because company and tag_type don't have
-- a direct relationship
INNER JOIN tag_company 
ON company.id=tag_company.company_id 
INNER JOIN tag_type 
ON tag_company.tag=tag_type.tag 
WHERE type='cloud'


-- find out which company in fortune500 (including the subsidiaries)

SELECT company_original.name, title, rank 
FROM company AS company_original 
LEFT JOIN company AS company_parent 
ON company_original.parent_id=company_parent.id 
INNER JOIN fortune500 
-- Use parent ticker if there is one, 
-- otherwise original ticker
ON coalesce(company_parent.ticker,
			company_original.ticker) = 
			fortune500.ticker 
ORDER BY rank;


-- How many of the Fortune 500 companies had revenues increase in 2017 compared to 2016?

SELECT COUNT(*)
FROM fortune500
WHERE revenues_change > 0 
