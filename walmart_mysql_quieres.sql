create database walmart_db;
use walmart_db;

SELECT 
    *
FROM
    walmart;

---
SELECT 
    COUNT(*)
FROM
    walmart;

select  payment_method, count(*)
from walmart
group by payment_method;

select count(distinct Branch)
from walmart;

select min(quantity) from walmart;

-- Business Problems
-- Q1.Find different payment methd and number of transactions , number of qty sold 

SELECT 
    payment_method,
    COUNT(payment_method) AS no_of_transactions,
    SUM(quantity) AS no_of_quantity
FROM
    walmart
GROUP BY payment_method
ORDER BY no_of_transactions DESC;

-- Q2. identify the heighest-rated category in each branch , displaying the branch , category, avg rating
SELECT Branch, category, avg_rating,rnk
FROM (
    SELECT 
        Branch, 
        category, 
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, category
) ranked_categories
WHERE rnk = 1;

-- Q3. Identify the busiest day for each branch based on the number of transactions.

SELECT * 
FROM (
    SELECT 
        Branch, 
        DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk 
    FROM walmart
    GROUP BY Branch, day_name
) AS ranked_transactions
WHERE rnk = 1
order by no_transactions desc;

-- Q4. Calculate the total quantity of items sold per payment method . list payment method and total_quantity

SELECT 
    payment_method, SUM(quantity) AS quantity_sold
FROM
    walmart
GROUP BY payment_method
ORDER BY quantity_sold DESC;

-- Q5. Determine the average,minimum and maximum rating ofcategory for each city. list the city ,average_rating,min_rating, and max_rating

SELECT 
    city,
    category,
    AVG(rating) AS average_rataing,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM
    walmart
GROUP BY city , category;

-- Q6 Calculate the total profit for each category by considering total_profit. list category and total_profit, orderd from heighest to lowest profit
SELECT 
    category,
    SUM(total) as total_revenue,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM
    walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7. Determine the most commomn payment method for each Branch.Display branch and the prefered payment method

WITH cte AS (
    SELECT 
        Branch, 
        payment_method, 
        COUNT(*) AS total_transaction,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, payment_method
)
SELECT *
FROM cte
WHERE rnk = 1;

-- Q8. Categorize sales into 3 groups morning afternoon and evening .find out which of the shift and number od invoices

SELECT 
    Branch,
    CASE 
        WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
        WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY  Branch,day_time
order by Branch, num_invoices;


-- Q9. identify 5 branch with heighest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
-- rdr = last_rev-cr_rev/ls_rev*100

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
