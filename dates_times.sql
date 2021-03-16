-- the answer on my query and on DataCamp is slightly difference because of the difference values in date_created

-- Count the number of Evanston 311 requests created on January 31, 2017
SELECT COUNT(*)
FROM evanston311
-- date_created data type is timestamp 
-- This is because dates are automatically converted to timestamps when compared to a timestamp
WHERE date_created::date = '2017-01-31';

-- Count the number of Evanston 311 requests 
-- created on February 29, 2016 by using >= and < operators
SELECT COUNT(*)
FROM evanston311
WHERE date_created >= '2016-02-29'
AND date_created < '2016-03-01';

-- Count the number of requests created on March 13, 2017
SELECT COUNT(*)
FROM evanston311
WHERE date_created >= '2017-03-13'
AND date_created < '2017-03-13'::date + 1;


-- Subtract the min date_created from the max
SELECT MAX(date_created) - MIN(date_created)
FROM evanston311; 

-- How old is the most recent request?
SELECT now() - max(date_created)
  FROM evanston311;

-- Add 100 days to the current timestamp
SELECT now() + '100 days'::interval;

-- Select the current timestamp, 
-- and the current timestamp + 5 minutes
SELECT now(), now() + '5 minutes'::interval;


-- Which category of Evanston 311 requests takes the longest to complete?
SELECT category,
-- we can compute average if we use group by 
AVG(date_completed - date_created) AS completion_time
FROM evanston311
GROUP BY category
ORDER BY completion_time DESC; 


-- how many requests are created in each of the 12 months during 2016-2017? 
SELECT date_part('month', date_created) AS month, COUNT(*)
FROM evanston311
WHERE date_part('year', date_created) >= 2016 
AND date_part('year', date_created) <= 2017
GROUP BY month; 

-- What is the most common hour of the day for requests to be created?
SELECT date_part('hour', date_created) AS hour, 
COUNT(*)
FROM evanston311
GROUP BY hour 
ORDER BY count DESC 
LIMIT 1; 

-- During what hours are requests usually completed? 
-- Count requests completed by hour.
SELECT date_part('hour', date_completed) AS hour, 
COUNT(*)
FROM evanston311
GROUP BY hour
ORDER BY count DESC; 

-- Does the time required to complete a request vary by the day of the week
-- on which the request was created?
SELECT to_char(date_created, 'day') AS day, 
AVG(date_completed - date_created) AS duration 
FROM evanston311
GROUP BY day, EXTRACT(DOW FROM date_created)
ORDER BY EXTRACT(DOW FROM date_created);


-- find the average number of Evanston 311 requests 
-- created per day for each month of the data
SELECT date_trunc('month',day) AS month, 
AVG(count)
FROM (SELECT date_trunc('day', date_created) AS day, 
	  COUNT(*) AS count
	  FROM evanston311
	  GROUP BY day) AS daily_count 
GROUP BY month 
ORDER BY month; 


-- Are there any days in the Evanston 311 data where no requests were created?
SELECT day 
FROM (SELECT generate_series(min(date_created), 
							max(date_created), 
							'1 day'::interval)::date AS day
	  FROM evanston311) AS all_dates 
WHERE day NOT IN 
(SELECT date_created::date 
FROM evanston311);


-- Find the median number of Evanston 311 requests per day 
-- in each six month period from 2016-01-01 to 2018-06-30
WITH bins AS (
	SELECT generate_series('2016-01-01', 
						   '2018-01-01',
						  '6 months'::interval) AS lower, 
			generate_series('2016-07-01', 
						   '2018-07-01', 
						   '6 months'::interval) AS upper), 
-- count a request made per day 
	daily_counts AS (
	SELECT day, count(date_created) AS count 
		FROM (SELECT generate_series('2016-01-01',
									 '2018-06-30',
									 '1 day'::interval)::date AS day)
		AS daily_series 
		LEFT JOIN evanston311
		ON day = date_created::date
		GROUP BY day)

SELECT lower, 
upper, percentile_disc(0.5) WITHIN GROUP (ORDER BY count) AS median
FROM bins 
LEFT JOIN daily_counts 
ON day >= lower 
AND day < upper 
GROUP BY lower, upper
ORDER BY lower; 


-- Find the average number of Evanston 311 requests created per day
-- for each month of the data
WITH all_days AS 
	(SELECT generate_series('2016-01-01',
						   '2018-06-30',
						   '1 day'::interval) AS date),
	daily_count AS 
	(SELECT date_trunc('day', date_created) AS day, 
				COUNT(*) AS count
	FROM evanston311
	GROUP BY day)
	
SELECT date_trunc('month', date) AS month, 
AVG(COALESCE(COUNT,0)) AS average 
FROM all_days 
LEFT JOIN daily_count
ON all_days.date=daily_count.day
GROUP BY month
ORDER BY month;


-- What is the longest time between Evanston 311 requests being submitted?
WITH request_gaps AS (
	SELECT date_created, 
	LAG(date_created) OVER (ORDER BY date_created) AS previous, 
	date_created - LAG(date_created) OVER (ORDER BY date_created) AS gap 
	FROM evanston311
)

SELECT * 
FROM request_gaps 
WHERE gap = (SELECT MAX(gap)
			FROM request_gaps)


-- examine the distribution of rat request completion times by number of days
SELECT date_trunc('day', date_completed - date_created) AS completion_time,
COUNT(*)
FROM evanston311
WHERE category = 'Rodents- Rats'
GROUP BY completion_time
ORDER BY completion_time; 


-- Compute average completion time per category excluding the longest 5% 
-- of requests (outliers)
SELECT category, 
AVG(date_completed - date_created) AS avg_completion_time
FROM evanston311
WHERE date_completed - date_created < 
(SELECT percentile_disc(.95) WITHIN GROUP (ORDER BY date_completed - date_created)
FROM evanston311)
GROUP BY category
ORDER BY avg_completion_time DESC; 


-- correlation between avg. completion time and monthly requests
SELECT corr(avg_completion, count)
FROM (SELECT date_trunc('month', date_created) AS month, 
	 AVG(EXTRACT(epoch FROM date_completed - date_created)) AS avg_completion, 
-- count by date_created as in month column
	 COUNT(*) AS count
	 FROM evanston311
	 WHERE category='Rodents- Rats'
	 GROUP BY month)
	 AS monthly_avgs;



-- Select the number of requests created and number of requests completed per month
WITH created AS (
	SELECT date_trunc('month', date_created) AS month, 
	COUNT(*) AS created_count 
	FROM evanston311
	WHERE category='Rodents- Rats'
	GROUP BY month
), 
	completed AS (
	SELECT date_trunc('month', date_completed) AS month, 
		COUNT(*) AS completed_count
		FROM evanston311
		WHERE category='Rodents- Rats'
		GROUP BY month
	)
	
SELECT created.month, 
created_count, 
completed_count
FROM created 
INNER JOIN completed 
ON created.month=completed.month
ORDER BY created.month; 