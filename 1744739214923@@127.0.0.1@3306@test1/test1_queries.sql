
INSERT into sales VALUES
('2025-01-01', 61),
('2025-01-02', 72),
('2025-01-04', 84),
('2025-01-05', 95),
('2025-01-07', 77);


INSERT into final_sales VALUES
('2025-01-01', 61),
('2025-01-02', 72),
('2025-01-03', 78),
('2025-01-04', 84),
('2025-01-05', 95),
('2025-01-06', 86),
('2025-01-07', 77);


-- Queries we will see:
-- UNION, UNION ALL, Subquery, LEFT JOIN, INNER JOIN, CTE, Recursive CTE, Date Expression,
-- CAST, COALESCE, ROUND, Window Functions

-- 1. view the table (note the missing dates)
SELECT * FROM sales;

-- 2. preview the final results
SELECT * FROM final_sales;

-- 3. generate a series of dates [UNION, UNION ALL]
-- UNION and UNION ALL both allow us to stack our select statements and the difference is with UNION duplicate values  will be removed whereas UNION ALL deson't remove duplicate values;
SELECT '2025-01-01' AS dt
UNION
SELECT '2025-01-02'
UNION
SELECT '2025-01-02'

SELECT '2025-01-01' AS dt
UNION ALL
SELECT '2025-01-02'
UNION ALL
SELECT '2025-01-02'


-- 4. join with our original table [Subquery, Left Join, Inner Join]
SELECT sq.dt, sales.num_sales FROM 
(SELECT '2025-01-01' AS dt
UNION ALL
SELECT '2025-01-02'
UNION ALL
SELECT '2025-01-03'
UNION ALL
SELECT '2025-01-04'
UNION ALL
SELECT '2025-01-05'
UNION ALL
SELECT '2025-01-06'
UNION ALL
SELECT '2025-01-07') AS sq

LEFT JOIN sales ON sq.dt = sales.dt;


-- 5. rewrite subquery as a CTE [CTE]
WITH cte AS (SELECT '2025-01-01' AS dt
            UNION ALL
            SELECT '2025-01-02'
            UNION ALL
            SELECT '2025-01-03'
            UNION ALL
            SELECT '2025-01-04'
            UNION ALL
            SELECT '2025-01-05'
            UNION ALL
            SELECT '2025-01-06'
            UNION ALL
            SELECT '2025-01-07')
SELECT cte.dt, sales.num_sales FROM cte
LEFT JOIN sales ON cte.dt = sales.dt;

-- 6. rewrite CTE as a recursive CTE [Recursive CTE, CAST Function]
-- in recursive CTE we can use recursion
WITH RECURSIVE cte AS (
                        SELECT CAST('2025-01-01' AS DATE) AS dt
                        UNION ALL
                        SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
                      )
SELECT cte.dt, sales.num_sales FROM cte
LEFT JOIN sales ON cte.dt = sales.dt;

-- 7. fill in null values [NULL Function, Numeric Function]
WITH RECURSIVE cte AS (
                        SELECT CAST('2025-01-01' AS DATE) AS dt
                        UNION ALL
                        SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
                      )
SELECT cte.dt, sales.num_sales,
       COALESCE(sales.num_sales, 0) AS sales_estimate,
       COALESCE(sales.num_sales, ROUND((SELECT AVG(num_sales) FROM sales), 1)) AS sales_estimate_2
FROM cte LEFT JOIN sales ON cte.dt = sales.dt;

-- 8. introduce window functions [Window Functions]
-- LAG returns prior row value and LEAD returns next row value
SELECT dt, num_sales,
       ROW_NUMBER() OVER(ORDER BY dt) AS row_num,
       LAG(num_sales) OVER(ORDER BY dt) AS prior_row,
       LEAD(num_sales) OVER(ORDER BY dt) AS next_row
FROM   sales;

-- 9. add on two window functions [Final Query]
-- ROUND function rounds the decimal value to the specified decimal precision
-- also here in this query if num_sales is null then consider the avg of prev & next value which we
-- can achieve via lag and lead functions
WITH RECURSIVE cte AS (
                        SELECT CAST('2025-01-01' AS DATE) AS dt
                        UNION ALL
                        SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
                      )
SELECT cte.dt, sales.num_sales,
       COALESCE(
        sales.num_sales, 
        ROUND((
            LAG(sales.num_sales) OVER (ORDER BY cte.dt) +
            LEAD(sales.num_sales) OVER (ORDER BY cte.dt)
        ) / 2, 1)
    ) AS sales_estimate
FROM cte LEFT JOIN sales ON cte.dt = sales.dt;



------------------------------------------------------------------------------------------------------------------

INSERT into baby_names VALUES
('Girl', 'Ava', 95),
('Girl', 'Emma', 106),
('Boy', 'Ethan', 115),
('Girl', 'Isabella', 100),
('Boy', 'Jacob', 101),
('Boy', 'Liam', 84),
('Boy', 'Logan', 73),
('Boy', 'Noah', 120),
('Girl', 'Olivia', 100),
('Girl', 'Sophia', 88);


-- 1. view the table
SELECT * FROM baby_names;

-- 2. order by popularity
SELECT * 
FROM baby_names
ORDER BY `Total` DESC;


-- 3. add a popularity column
-- window function has 2 parts the second part is the window and first part is the fucntion. So the way to think about it is your window here is how we wanna view our data when we apply our function.
SELECT `Gender`, `Name`, `Total`,
       ROW_NUMBER() OVER(ORDER BY `Total` DESC) AS Popularity
FROM baby_names;

-- 4. try different functions
SELECT `Gender`, `Name`, `Total`,
       ROW_NUMBER() OVER(ORDER BY `Total` DESC) AS Popularity,
       RANK() OVER(ORDER BY `Total` DESC) AS Popularity_R,
       DENSE_RANK() OVER(ORDER BY `Total` DESC) AS Popularity_DR
FROM baby_names;

-- 5. try different windows
-- now we want to see popularity of each group, here we have a boy and a girl group
SELECT `Gender`, `Name`, `Total`,
       ROW_NUMBER() OVER(PARTITION BY `Gender` ORDER BY `Total` DESC) AS Popularity
FROM baby_names;

-- 6. what are the top 3 most popular names for each gender?

SELECT * FROM

(SELECT `Gender`, `Name`, `Total`,
       ROW_NUMBER() OVER(PARTITION BY `Gender` ORDER BY `Total` DESC) AS Popularity
FROM baby_names) AS pop

WHERE Popularity <= 3;




---------------------------------------------------------------------------------------------------------------


INSERT into menu_items VALUES
(101, 'Hamburger', 'American', 12.95),
(102, 'Cheeseburger', 'American', 13.95),
(103, 'Hot Dog', 'American', 9.00),
(104, 'Veggie Burger', 'American', 10.50),
(105, 'Mac & Cheese', 'American', 7.00),
(106, 'Frence Fries', 'American', 7.00),
(107, 'Orange Chicken', 'Asian', 16.50),
(108, 'Chicken Kadai', 'Asian', 17.50),
(109, 'Tacos', 'Mexican', 14.95),
(110, 'Pizza', 'Italian', 19.95);


-- 1. How many categories have a maximum price below $15?


-- 1a. What's the max price for each category?
SELECT category, MAX(price) AS max_price
FROM menu_items
GROUP BY category;

-- 1b. How many max prices are less than $15?

-- subquery
SELECT COUNT(*) FROM
(SELECT category, MAX(price) AS max_price
FROM menu_items
GROUP BY category) AS mp
WHERE max_price < 15;

-- cte
WITH mp AS (SELECT category, MAX(price) AS max_price
            FROM menu_items
            GROUP BY category)
SELECT COUNT(*) 
FROM mp
WHERE max_price < 15;

-- 2. CTE: Multiple refernces
WITH mp AS (SELECT category, MAX(price) AS max_price
            FROM menu_items
            GROUP BY category)
SELECT COUNT(*) 
FROM mp
WHERE max_price < (SELECT AVG(max_price) FROM mp);

-- 3. CTE: Multiple tables
WITH mp AS (SELECT category, MAX(price) AS max_price
            FROM menu_items
            GROUP BY category),
     ci AS (SELECT *
            FROM menu_items
            WHERE item_name LIKE '%Chicken%')
SELECT *
FROM ci LEFT JOIN mp ON ci.category = mp.category;















