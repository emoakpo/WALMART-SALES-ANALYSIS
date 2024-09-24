SELECT * FROM walmartsd;

CREATE TABLE walmartsd2 LIKE walmartsd;
INSERT walmartsd2
SELECT * FROM walmartsd;

SELECT *,
ROW_NUMBER () OVER (
partition by `Invoice ID`) as row_num
FROM walmartsd2;

-- CONVERT  the `date` to a date datatype
ALTER TABLE walmartsd2
MODIFY COLUMN `date` DATE;

-- CONVERT  the `time` to a date datatype
ALTER TABLE walmartsd2
MODIFY COLUMN `Time` time;

-- CHECK FOR NULL values
SELECT *
FROM walmartsd2
WHERE `Invoice ID` IS NULL;


-- FEATURE ENGINEERING
-- ----------------------------------------------
-- time_of_day
SELECT `time`, (CASE
WHEN `time` between '00:00:00' and '12:00:00' then 'MORNING'
WHEN `time` between '12:01:00' and '16:00:00' then 'AFTERNOON'
ELSE 'EVENING' 
END) AS time_of_day from walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmartsd2
SET time_of_day = (CASE
WHEN `time` between '00:00:00' and '12:00:00' then 'MORNING'
WHEN `time` between '12:01:00' and '16:00:00' then 'AFTERNOON'
ELSE 'EVENING' 
END);


-- day_name

SELECT `date`, DAYNAME(`date`) FROM walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN day_name VARCHAR(20);

UPDATE walmartsd2
SET day_name = DAYNAME(`date`);

-- month_name
SELECT `date`, MONTHNAME(`date`)
FROM walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN month_name VARCHAR(20);

UPDATE walmartsd2
SET month_name = MONTHNAME(`date`);




-- -----------------------------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS -----------------------------


/* Business Questions To Answer
Generic Question
1. How many unique cities does the data have?
2. In which city is each branch? */

SELECT DISTINCT City FROM walmartsd2;

SELECT DISTINCT CITY, branch FROM walmartsd2;


-- -----------------------------------------------------------------------
-- Product
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT `product line`)
FROM walmartsd2;

-- What is the most common payment method?

SELECT PAYMENT, COUNT(PAYMENT) FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;


-- What is the most selling product line?
SELECT `Product line`, COUNT(`Product line`)
FROM walmartsd2
group by 1
order by 2 DESC;

-- What is the total revenue by month?
SELECT month_name AS MONTH, Sum(Total) AS `TOTAL REVENUE`
FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- What month had the largest COGS?
SELECT  month_name, SUM(cogs)
FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- What product line had the largest revenue?
SELECT `PRODUCT LINE`, SUM(TOTAL) AS `Total Revenue`
FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- What is the city with the largest revenue?
SELECT Branch, `CITY`, SUM(TOTAL) AS `Total Revenue`
FROM walmartsd2
GROUP BY 2,1
ORDER BY 3 DESC;


-- What product line had the largest VAT?

SELECT `Product line`, avg(`Tax 5%`) AS `Tax`
FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT * FROM walmartsd2;

Which branch sold more products than average product sold?
What is the most common product line by gender?
What is the average rating of each product line?

SELECT * FROM walmartsd2;

