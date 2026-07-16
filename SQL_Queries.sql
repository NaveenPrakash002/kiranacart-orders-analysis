-- ==========================================
-- E-Commerce Sales Analysis (PostgreSQL)
-- ==========================================

-- 1. Total Number of Orders
SELECT
    COUNT(*) AS total_orders
FROM orders;


-- 2. Monthly Revenue
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(order_total) AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY month;


-- 3. Top 5 Customers by Number of Orders
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 5;


-- 4. Orders Without Payments (Anti Join)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date
FROM orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM payments AS p
    WHERE p.order_id = o.order_id
);


-- 5. Average Order Value by State
SELECT
    c.state AS region,
    ROUND(AVG(o.order_total), 2) AS average_order_value
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_total IS NOT NULL
GROUP BY c.state
ORDER BY average_order_value DESC;


-- 6. Top 10 Customers by Lifetime Revenue
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    SUM(o.order_total) AS lifetime_revenue,
    COUNT(*) AS delivered_orders
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
WHERE o.status = 'DELIVERED'
  AND o.order_total IS NOT NULL
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY lifetime_revenue DESC
LIMIT 10;


-- 7. Revenue Contribution by Product Category
WITH cat_rev AS (
    SELECT
        p.category,
        SUM(oi.line_total) AS revenue
    FROM order_items oi
    JOIN orders o
        ON o.order_id = oi.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    WHERE o.status = 'DELIVERED'
    GROUP BY p.category
)
SELECT
    category,
    revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        1
    ) AS pct_of_total
FROM cat_rev
ORDER BY revenue DESC;


-- 8. Repeat Customer Rate
WITH per_customer AS (
    SELECT
        customer_id,
        COUNT(*) AS delivered_orders
    FROM orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS customers_who_ordered,
    COUNT(*) FILTER (WHERE delivered_orders >= 2) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivered_orders >= 2) / COUNT(*),
        1
    ) AS repeat_customer_rate
FROM per_customer;


-- 9. Average Order Value Comparison
-- Business AOV (Correct)
SELECT
    ROUND(SUM(order_total) / COUNT(*), 2) AS aov_business
FROM orders
WHERE status = 'DELIVERED';

-- Naive AOV (Incorrect if NULL order_total exists)
SELECT
    ROUND(AVG(order_total), 2) AS aov_naive_avg
FROM orders
WHERE status = 'DELIVERED';


-- 10. Running Revenue Total (Window Function)
SELECT
    order_date,
    SUM(order_total) AS daily_revenue,
    SUM(SUM(order_total)) OVER (
        ORDER BY order_date
    ) AS running_revenue
FROM orders
WHERE status = 'DELIVERED'
  AND order_total IS NOT NULL
GROUP BY order_date
ORDER BY order_date;


-- 11. Customer Rank by Total Spend (Window Function)
SELECT
    c.customer_id,
    c.full_name,
    ROUND(SUM(o.order_total), 2) AS total_spent,
    RANK() OVER (
        ORDER BY SUM(o.order_total) DESC
    ) AS customer_rank
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status = 'DELIVERED'
  AND o.order_total IS NOT NULL
GROUP BY c.customer_id, c.full_name
ORDER BY customer_rank;


-- 12. Month-over-Month Revenue Growth (LAG)
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(order_total) AS revenue
    FROM orders
    WHERE status = 'DELIVERED'
      AND order_total IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month),
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY month;-- ==========================================
-- E-Commerce Sales Analysis (PostgreSQL)
-- ==========================================

-- 1. Total Number of Orders
SELECT
    COUNT(*) AS total_orders
FROM orders;


-- 2. Monthly Revenue
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(order_total) AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY month;


-- 3. Top 5 Customers by Number of Orders
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 5;


-- 4. Orders Without Payments (Anti Join)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date
FROM orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM payments AS p
    WHERE p.order_id = o.order_id
);


-- 5. Average Order Value by State
SELECT
    c.state AS region,
    ROUND(AVG(o.order_total), 2) AS average_order_value
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_total IS NOT NULL
GROUP BY c.state
ORDER BY average_order_value DESC;


-- 6. Top 10 Customers by Lifetime Revenue
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    SUM(o.order_total) AS lifetime_revenue,
    COUNT(*) AS delivered_orders
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
WHERE o.status = 'DELIVERED'
  AND o.order_total IS NOT NULL
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY lifetime_revenue DESC
LIMIT 10;


-- 7. Revenue Contribution by Product Category
WITH cat_rev AS (
    SELECT
        p.category,
        SUM(oi.line_total) AS revenue
    FROM order_items oi
    JOIN orders o
        ON o.order_id = oi.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    WHERE o.status = 'DELIVERED'
    GROUP BY p.category
)
SELECT
    category,
    revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        1
    ) AS pct_of_total
FROM cat_rev
ORDER BY revenue DESC;


-- 8. Repeat Customer Rate
WITH per_customer AS (
    SELECT
        customer_id,
        COUNT(*) AS delivered_orders
    FROM orders
    WHERE status = 'DELIVERED'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS customers_who_ordered,
    COUNT(*) FILTER (WHERE delivered_orders >= 2) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivered_orders >= 2) / COUNT(*),
        1
    ) AS repeat_customer_rate
FROM per_customer;


-- 9. Average Order Value Comparison
-- Business AOV (Correct)
SELECT
    ROUND(SUM(order_total) / COUNT(*), 2) AS aov_business
FROM orders
WHERE status = 'DELIVERED';

-- Naive AOV (Incorrect if NULL order_total exists)
SELECT
    ROUND(AVG(order_total), 2) AS aov_naive_avg
FROM orders
WHERE status = 'DELIVERED';


-- 10. Running Revenue Total 
SELECT
    order_date,
    SUM(order_total) AS daily_revenue,
    SUM(SUM(order_total)) OVER (
        ORDER BY order_date
    ) AS running_revenue
FROM orders
WHERE status = 'DELIVERED'
  AND order_total IS NOT NULL
GROUP BY order_date
ORDER BY order_date;


-- 11. Customer Rank by Total Spend
SELECT
    c.customer_id,
    c.full_name,
    ROUND(SUM(o.order_total), 2) AS total_spent,
    RANK() OVER (
        ORDER BY SUM(o.order_total) DESC
    ) AS customer_rank
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status = 'DELIVERED'
  AND o.order_total IS NOT NULL
GROUP BY c.customer_id, c.full_name
ORDER BY customer_rank;


-- 12. Month-over-Month Revenue Growth
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(order_total) AS revenue
    FROM orders
    WHERE status = 'DELIVERED'
      AND order_total IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month),
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY month;
