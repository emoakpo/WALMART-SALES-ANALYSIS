/* CLEANING*/
-- --------------------------------------------------------------------------------------
SELECT 
    *
FROM
    walmartsd;

/*DUPLICATING TABLE TO WORK WITH KEEPIN ORIGINAL INTACT*/
CREATE TABLE walmartsd2 LIKE walmartsd;
INSERT walmartsd2
SELECT * FROM walmartsd;

/*CHECKIN FOR DUPLICATE ROW IN TABLE*/
SELECT *,
ROW_NUMBER () OVER (
partition by `Invoice ID`) as row_num
FROM walmartsd2;

/*CONVERT  the `date` to a date datatype*/
ALTER TABLE walmartsd2
MODIFY COLUMN `date` DATE;

/* CONVERT  the `time` to a TIME datatype */
ALTER TABLE walmartsd2
MODIFY COLUMN `Time` time;

/* CHECK FOR NULL values */
SELECT 
    *
FROM
    walmartsd2
WHERE
    `Invoice ID` IS NULL;


/* FEATURE ENGINEERING */
-- -----------------------------------------------------------------------------------------
/* TIME OF DAY*/
-- ----------------------------------------------------------------------------------------
SELECT 
    `time`,
    (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END) AS time_of_day
FROM
    walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmartsd2 
SET 
    time_of_day = (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
    END);


/*DAY NAME*/
-- -------------------------------------------------------------------------------------
SELECT 
    `date`, DAYNAME(`date`)
FROM
    walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN day_name VARCHAR(20);

UPDATE walmartsd2 
SET 
    day_name = DAYNAME(`date`);
    

/*MONTH NAME*/
-- -----------------------------------------------------------------------------------------------------
SELECT 
    `date`, MONTHNAME(`date`)
FROM
    walmartsd2;

ALTER TABLE walmartsd2 ADD COLUMN month_name VARCHAR(20);

UPDATE walmartsd2 
SET 
    month_name = MONTHNAME(`date`);

-- -----------------------------------------------------------------------------------
/* EXPLORATORY DATA ANALYSIS*/
-- -----------------------------------------------------------------------------------
/* LIST OF CITY */
SELECT DISTINCT
    City
FROM
    walmartsd2;
-- -------------------------------------------------------------------------------------

/* LIST OF BRANCH*/
SELECT DISTINCT
    CITY, branch
FROM
    walmartsd2;
-- --------------------------------------------------------------------------------------

/*PRODUCT*/
-- --------------------------------------------------------------------------------------
-- How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT `product line`)
FROM
    walmartsd2;
-- --------------------------------------------------------------------------------------
-- What is the most common payment method?
SELECT 
    PAYMENT, COUNT(PAYMENT)
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ---------------------------------------------------------------------------------------
-- What is the most selling product line?
SELECT 
    `Product line`, COUNT(`Product line`)
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- -------------------------------------------------------------------------------------
-- What is the total revenue by month?
SELECT 
    month_name AS MONTH, SUM(Total) AS `TOTAL REVENUE`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- What month had the largest COGS?
SELECT 
    month_name, SUM(cogs)
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- What product line had the largest revenue?
SELECT 
    `PRODUCT LINE`, SUM(TOTAL) AS `Total Revenue`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- What is the city with the largest revenue?
SELECT 
    Branch, `CITY`, SUM(TOTAL) AS `Total Revenue`
FROM
    walmartsd2
GROUP BY 2 , 1
ORDER BY 3 DESC;

-- ------------------------------------------------------------------------------------
-- What product line had the largest VAT?
SELECT 
    `Product line`, AVG(`Tax 5%`) AS `Tax`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT
    `product line`,
    ROUND(SUM(total), 2),
    CASE
        WHEN SUM(total) > (SELECT AVG(TOTAL) FROM walmartsd2) THEN 'Good'
        ELSE 'Bad'
    END AS sales_category
FROM walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- Which branch sold more products than average product sold?
SELECT 
    Branch, SUM(Quantity) AS QTY
FROM
    walmartsd2
GROUP BY 1
HAVING SUM(Quantity) > (SELECT 
        AVG(Quantity)
    FROM
        walmartsd2);

-- ------------------------------------------------------------------------------------
-- What is the most common product line by gender?
SELECT 
    gender, `Product line`, COUNT(gender) AS Total_Count
FROM
    walmartsd2
GROUP BY 1 , 2
ORDER BY 2;

-- ------------------------------------------------------------------------------------
-- What is the average rating of each product line?
SELECT 
    ROUND(AVG(Rating), 2) AS `AVERAGE RATING`, `PRODUCT LINE`
FROM
    walmartsd2
GROUP BY 2
ORDER BY 1 DESC;

-- ------------------------------------------------------------------------------------

/*SALES*/
-- -----------------------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT 
    day_name AS `WEEK DAY`,
    time_of_day AS `TIME OF THE DAY`,
    COUNT(*) AS `NUMBER OF SALES`
FROM
    walmartsd2
GROUP BY 1 , 2
ORDER BY 1 , 2;

-- ------------------------------------------------------------------------------------
-- Which of the customer types brings the most revenue?
SELECT 
    `Customer type`, ROUND(SUM(Total), 2) AS REVENUE
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
    city,
    MAX(`tax 5%`) AS `MAX TAX`,
    ROUND(AVG(`tax 5%`), 2) AS `AVG TAX`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- Which customer type pays the most in VAT?
SELECT 
    `Customer type`, ROUND(AVG(`tax 5%`), 2) AS `AVG TAX`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
/*Customer*/
-- ------------------------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT
    `Customer type`
FROM
    walmartsd2;

-- ------------------------------------------------------------------------------------
-- How many unique payment methods does the data have?
SELECT DISTINCT
    `Payment`
FROM
    walmartsd2;

-- ------------------------------------------------------------------------------------
-- What is the most common customer type?
SELECT 
    `customer type`, COUNT(*) AS total_customers
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- ------------------------------------------------------------------------------------
-- Which customer type buys the most?
SELECT 
    `Customer type`, COUNT(*) AS `customer count`
FROM
    walmartsd2
GROUP BY 1;

-- ------------------------------------------------------------------------------------
-- What is the gender of most of the customers?
SELECT 
    GENDER, COUNT(*) AS `GENDER COUNT`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- What is the gender distribution per branch?
SELECT 
    GENDER, COUNT(*) `GENDER COUNT`
FROM
    walmartsd2
WHERE
    BRANCH = 'A'
GROUP BY 1
ORDER BY 2;

-- ------------------------------------------------------------------------------------
-- Which time of the day do customers give most ratings?
SELECT 
    time_of_day, ROUND(AVG(Rating), 2) AS `AVG RATING`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;
  
-- ------------------------------------------------------------------------------------
-- Which time of the day do customers give most ratings per branch?
SELECT 
    branch, time_of_day, COUNT(*) AS total_ratings
FROM
    walmartsd2
GROUP BY 1 , 2
ORDER BY 3 DESC;

-- ------------------------------------------------------------------------------------
-- Which day fo the week has the best avg ratings?
SELECT 
    day_name, ROUND(AVG(rating), 2) AS `AVERAGE RATING`
FROM
    walmartsd2
GROUP BY 1
ORDER BY 2 DESC;

-- ------------------------------------------------------------------------------------
-- Which day of the week has the best average ratings per branch?
SELECT 
    branch, day_name, ROUND(AVG(rating), 2) AS `AVERAGE RATING`
FROM
    walmartsd2
GROUP BY 1 , 2
ORDER BY 1 , 2 , 3 DESC;