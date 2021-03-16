-- how many rows does each priority level have?
SELECT priority, COUNT(*)
FROM evanston311
GROUP BY priority; 

-- How many distinct values of zip appear in at least 100 rows?
SELECT zip, COUNT(*)
FROM evanston311
GROUP BY zip
HAVING COUNT(*) > 100;

-- How many distinct values of source appear in at least 100 rows?
SELECT source, COUNT(*)
FROM evanston311
GROUP BY source
HAVING COUNT(*) >= 100; 

-- Select the five most common values of street and the count of each
SELECT street, COUNT(*)
FROM evanston311
GROUP BY street
ORDER BY COUNT(*) DESC 
LIMIT 5;

-- Some of the street values in evanston311 include house numbers with # or / in them. 
-- In addition, some street values end in a '.'
SELECT DISTINCT street, 
TRIM(street, '0123456789 #/.') AS cleaned_street
FROM evanston311
ORDER BY street; 


-- count rows in evanston311 where the description contains
-- 'trash' or 'garbage' regardless of case. 
SELECT COUNT(*)
FROM evanston311
WHERE description ILIKE '%trash%'
OR description ILIKE '%garbage%';

-- Select categories containing Trash or Garbage
SELECT category
  FROM evanston311
 -- Use LIKE
 WHERE category LIKE '%Trash%'
    OR category LIKE '%Garbage%';

-- Count rows where the description includes 'trash' or 'garbage' but the category does not
SELECT COUNT(*)
  FROM evanston311 
 -- description contains trash or garbage (any case)
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
 -- category does not contain Trash or Garbage
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%';


-- Find the most common categories for rows with a description 
-- about 'trash' that don't have a trash-related 'category'.
SELECT COUNT(*), category 
FROM evanston311
WHERE (description ILIKE '%trash'
	  OR description ILIKE '%garbage%')
	  AND category NOT LIKE '%Trash%'
	  AND category NOT LIKE '%Garbage%'
GROUP BY category
ORDER BY COUNT(*) DESC
LIMIT 10; 
-- The results include some categories that appear to be related to trash, while others are more general.


-- concatenate house_num, a space, and street into address column
-- trim spaces from the start of the result to remove any spaces from the start
SELECT LTRIM(CONCAT(house_num, ' ', street)) AS address
FROM evanston311;


-- select the first word of the street value
SELECT split_part(street, ' ', 1) AS street_name, 
COUNT(*)
FROM evanston311
GROUP BY street_name
ORDER BY count DESC 
LIMIT 20; 


-- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50 
THEN LEFT(description, 50) || '...'
ELSE description 
END 
FROM evanston311
WHERE description LIKE 'I %'
ORDER BY description; 


-- There are almost 150 distinct values of evanston311.category
-- But some of these categories are similar, with the form "Main Category - Details"
-- We can get a better sense of what requests are common if we aggregate by the main category
DROP TABLE IF EXISTS recode; 
CREATE TEMP TABLE recode AS 
SELECT DISTINCT category, 
RTRIM(split_part(category, '-', 1)) AS standardized 
FROM evanston311; 
-- look at few value 
SELECT DISTINCT standardized 
FROM recode 
WHERE standardized LIKE 'Trash%Cart'
OR standardized LIKE 'Snow%Removal';

-- update to group trash cart values
UPDATE recode 
SET standardized='Trash Cart'
WHERE standardized LIKE 'Trash%Cart';

-- update to group snow removal values 
UPDATE recode 
SET standardized='Snow Removal'
WHERE standardized LIKE 'Snow%Removal';

-- examine the effect
SELECT DISTINCT standardized 
FROM recode 
WHERE standardized LIKE 'Trash%Cart'
OR standardized LIKE 'Snow%Removal';

UPDATE recode
SET standardized='UNUSED'
WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart',
					  '(DO NOT USE) Water Bill', 
					  'DO NOT USE Trash', 
					  'NO LONGER IN USE');
					  
-- examine effect on updates
SELECT DISTINCT standardized 
FROM recode 
ORDER BY standardized;

-- join the evanston311 and recode tables 
-- to count the number of requests with each of the standardized values
SELECT standardized, COUNT(*)
FROM evanston311
LEFT JOIN recode
ON evanston311.category=recode.category
GROUP BY standardized 
ORDER BY COUNT(*) DESC; 
-- the query is resulting in the most common standardized value 


-- Determine whether medium and high priority requests in the evanston311 data 
-- are more likely to contain requesters' contact information: an email address or phone number
DROP TABLE IF EXISTS indicators; 

CREATE TEMP TABLE indicators AS 
SELECT id, 
CAST(description LIKE '%@%' AS integer) AS email, 
CAST(description LIKE '%___-___-____' AS integer) AS phone 
FROM evanston311; 

SELECT priority, 
SUM(email)/COUNT(*)::numeric AS email_prop, 
SUM(phone)/COUNT(*)::numeric AS phone_prop
FROM evanston311 
LEFT JOIN indicators 
ON evanston311.id=indicators.id
GROUP BY priority;