-- =====================================================================
-- SQL E-commerce Report | Week 4 | 03_queries.sql  (40 analytical queries)
-- Revenue rule: only orders NOT in ('cancelled','returned') count as revenue.
-- Every query is preceded by a "-- Qn:" title line.
-- =====================================================================

-- ############ SECTION A: BASICS & FILTERING ############

-- Q1: Customers from Bengaluru
SELECT customer_id, first_name, last_name, email FROM customers WHERE city = 'Bengaluru' ORDER BY last_name;

-- Q2: Products priced above 1000, most expensive first
SELECT name, unit_price FROM products WHERE unit_price > 1000 ORDER BY unit_price DESC;

-- Q3: Orders placed in Q1 2026
SELECT order_id, customer_id, order_date, status FROM orders WHERE order_date BETWEEN '2026-01-01' AND '2026-03-31' ORDER BY order_date;

-- Q4: Customers with a Gmail address (pattern matching)
SELECT first_name, last_name, email FROM customers WHERE email LIKE '%@gmail.com';

-- Q5: Orders that are pending or shipped (IN list) and used a coupon
SELECT order_id, status, coupon_code FROM orders WHERE status IN ('pending','shipped') AND coupon_code IS NOT NULL;

-- ############ SECTION B: TOP PRODUCTS ############

-- Q6: Top 5 products by revenue
SELECT p.name, SUM(l.line_total) AS revenue, SUM(l.quantity) AS units
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY p.product_id, p.name ORDER BY revenue DESC LIMIT 5;

-- Q7: Top 5 products by units sold
SELECT p.name, SUM(l.quantity) AS units_sold
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY p.product_id, p.name ORDER BY units_sold DESC, p.name LIMIT 5;

-- Q8: Best-selling product in each category (window function)
WITH rev AS (
  SELECT COALESCE(c.name,'Uncategorised') AS category, p.name AS product, SUM(l.line_total) AS revenue
  FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
  LEFT JOIN categories c ON c.category_id = p.category_id
  WHERE l.status NOT IN ('cancelled','returned') GROUP BY c.name, p.product_id, p.name),
ranked AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn FROM rev)
SELECT category, product, revenue FROM ranked WHERE rn = 1 ORDER BY revenue DESC;

-- Q9: Revenue and share by category
SELECT COALESCE(c.name,'Uncategorised') AS category,
       ROUND(SUM(l.line_total),2) AS revenue,
       ROUND(100.0 * SUM(l.line_total) / SUM(SUM(l.line_total)) OVER (), 1) AS pct_of_total
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY c.name ORDER BY revenue DESC;

-- Q10: Gross margin per product (NULLIF avoids divide-by-zero, NULL cost stays NULL)
SELECT name, unit_price, cost_price,
       ROUND(100.0 * (unit_price - cost_price) / NULLIF(unit_price,0), 1) AS margin_pct
FROM products ORDER BY margin_pct DESC;

-- Q11: Products that were never ordered (anti-join)
SELECT p.product_id, p.name, p.discontinued
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- Q12: Monthly revenue trend
SELECT strftime('%Y-%m', order_date) AS month, ROUND(SUM(line_total),2) AS revenue, COUNT(DISTINCT order_id) AS orders
FROM v_order_lines WHERE status NOT IN ('cancelled','returned')
GROUP BY month ORDER BY month;

-- ############ SECTION C: CUSTOMER SPEND ############

-- Q13: Top 10 customers by lifetime spend
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer, ROUND(SUM(l.line_total),2) AS total_spend
FROM customers c JOIN v_order_lines l ON l.customer_id = c.customer_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY c.customer_id ORDER BY total_spend DESC LIMIT 10;

-- Q14: Average order value (AOV) per customer
WITH order_totals AS (
  SELECT order_id, customer_id, SUM(line_total) AS order_total FROM v_order_lines
  WHERE status NOT IN ('cancelled','returned') GROUP BY order_id, customer_id)
SELECT customer_id, COUNT(*) AS orders, ROUND(AVG(order_total),2) AS aov, ROUND(MAX(order_total),2) AS biggest_order
FROM order_totals GROUP BY customer_id ORDER BY aov DESC LIMIT 10;

-- Q15: Customer tiers with CASE
WITH spend AS (
  SELECT c.customer_id, c.first_name, COALESCE(SUM(l.line_total),0) AS total
  FROM customers c LEFT JOIN v_order_lines l ON l.customer_id = c.customer_id AND l.status NOT IN ('cancelled','returned')
  GROUP BY c.customer_id)
SELECT CASE WHEN total >= 20000 THEN 'Gold' WHEN total >= 8000 THEN 'Silver' WHEN total > 0 THEN 'Bronze' ELSE 'No purchases' END AS tier,
       COUNT(*) AS customers, ROUND(SUM(total),2) AS tier_revenue
FROM spend GROUP BY tier ORDER BY tier_revenue DESC;

-- Q16: Customers who never placed an order
SELECT c.customer_id, c.first_name, c.last_name, c.signup_date
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id WHERE o.order_id IS NULL;

-- Q17: Repeat customers (HAVING)
SELECT customer_id, COUNT(*) AS orders_placed, MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM orders GROUP BY customer_id HAVING COUNT(*) >= 4 ORDER BY orders_placed DESC;

-- Q18: Revenue by city (NULL city shown as 'Unknown')
SELECT COALESCE(c.city,'Unknown') AS city, COUNT(DISTINCT c.customer_id) AS customers, ROUND(SUM(l.line_total),2) AS revenue
FROM customers c JOIN v_order_lines l ON l.customer_id = c.customer_id
WHERE l.status NOT IN ('cancelled','returned') GROUP BY c.city ORDER BY revenue DESC;

-- Q19: Running total of spend for customer 3 (window)
WITH o AS (SELECT order_id, order_date, SUM(line_total) AS amt FROM v_order_lines
           WHERE customer_id = 3 AND status NOT IN ('cancelled','returned') GROUP BY order_id, order_date)
SELECT order_date, order_id, ROUND(amt,2) AS order_amt,
       ROUND(SUM(amt) OVER (ORDER BY order_date, order_id),2) AS running_total FROM o ORDER BY order_date, order_id;

-- Q20: Customer ranking with RANK and DENSE_RANK
WITH s AS (SELECT customer_id, SUM(line_total) AS total FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY customer_id)
SELECT customer_id, ROUND(total,2) AS total, RANK() OVER (ORDER BY total DESC) AS rnk, DENSE_RANK() OVER (ORDER BY total DESC) AS dense_rnk,
       NTILE(4) OVER (ORDER BY total DESC) AS quartile
FROM s ORDER BY rnk LIMIT 10;

-- ############ SECTION D: NULL HANDLING ############

-- Q21: Customers missing a phone number (IS NULL, never = NULL)
SELECT customer_id, first_name, last_name FROM customers WHERE phone IS NULL;

-- Q22: COALESCE to display friendly text
SELECT customer_id, first_name, COALESCE(phone,'not provided') AS phone, COALESCE(city,'Unknown') AS city FROM customers LIMIT 10;

-- Q23: COUNT(*) vs COUNT(column) - NULLs are skipped by COUNT(col)
SELECT COUNT(*) AS all_customers, COUNT(phone) AS with_phone, COUNT(city) AS with_city, COUNT(*) - COUNT(phone) AS missing_phone FROM customers;

-- Q24: AVG ignores NULL; compare with treating NULL as 0
SELECT ROUND(AVG(rating),2) AS avg_ignoring_null, ROUND(AVG(COALESCE(rating,0)),2) AS avg_null_as_zero,
       COUNT(*) AS reviews, COUNT(rating) AS rated FROM reviews;

-- Q25: Orders not yet shipped (excluding cancelled)
SELECT order_id, customer_id, order_date, status FROM orders WHERE shipped_date IS NULL AND status <> 'cancelled' ORDER BY order_date;

-- Q26: Average days to ship (NULL shipped_date rows are ignored automatically)
SELECT ROUND(AVG(julianday(shipped_date) - julianday(order_date)),2) AS avg_days_to_ship, COUNT(shipped_date) AS shipped_orders, COUNT(*) - COUNT(shipped_date) AS not_shipped FROM orders;

-- Q27: NOT IN trap vs NOT EXISTS: products.category_id contains a NULL
--      NOT IN returns 0 rows (NULL makes the comparison UNKNOWN); NOT EXISTS is correct.
SELECT 'NOT IN' AS method, COUNT(*) AS empty_categories FROM categories WHERE category_id NOT IN (SELECT category_id FROM products)
UNION ALL
SELECT 'NOT EXISTS', COUNT(*) FROM categories c WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.category_id = c.category_id);

-- Q28: Sort NULLs last
SELECT order_id, status, shipped_date FROM orders ORDER BY shipped_date IS NULL, shipped_date DESC LIMIT 10;

-- Q29: Coupon usage with NULL bucket labelled
SELECT COALESCE(coupon_code,'NO COUPON') AS coupon, COUNT(*) AS orders FROM orders GROUP BY coupon_code ORDER BY orders DESC;

-- Q30: NULL discount treated as 0 vs. discounted lines
SELECT CASE WHEN discount_pct IS NULL THEN 'no discount recorded' WHEN discount_pct = 0 THEN '0%' ELSE 'discounted' END AS bucket,
       COUNT(*) AS lines FROM order_items GROUP BY bucket;

-- ############ SECTION E: JOINs ############

-- Q31: INNER JOIN - full order detail
SELECT o.order_id, c.first_name, p.name AS product, oi.quantity, oi.unit_price
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id LIMIT 10;

-- Q32: LEFT JOIN - every category with product count (empty categories included)
SELECT c.name AS category, COUNT(p.product_id) AS products FROM categories c LEFT JOIN products p ON p.category_id = c.category_id GROUP BY c.category_id ORDER BY products DESC;

-- Q33: LEFT JOIN + COALESCE - products without a category
SELECT p.name, COALESCE(c.name,'Uncategorised') AS category FROM products p LEFT JOIN categories c ON c.category_id = p.category_id WHERE c.category_id IS NULL;

-- Q34: SELF JOIN - who referred whom
SELECT r.first_name || ' ' || r.last_name AS customer, COALESCE(ref.first_name || ' ' || ref.last_name,'(organic)') AS referred_by
FROM customers r LEFT JOIN customers ref ON ref.customer_id = r.referred_by ORDER BY r.customer_id LIMIT 12;

-- Q35: Referrers ranked by how many customers they brought in
SELECT ref.first_name || ' ' || ref.last_name AS referrer, COUNT(*) AS referrals
FROM customers c JOIN customers ref ON ref.customer_id = c.referred_by GROUP BY ref.customer_id ORDER BY referrals DESC;

-- Q36: Orders with no payment record (shipped/delivered but unpaid data gap)
SELECT o.order_id, o.status, o.order_date FROM orders o LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL AND o.status IN ('shipped','delivered') ORDER BY o.order_id;

-- Q37: FULL OUTER JOIN emulation (portable): products vs reviews
SELECT p.name, r.review_id FROM products p LEFT JOIN reviews r ON r.product_id = p.product_id WHERE r.review_id IS NULL
UNION
SELECT p.name, r.review_id FROM reviews r LEFT JOIN products p ON p.product_id = r.product_id WHERE p.product_id IS NULL;

-- Q38: CROSS JOIN - category x status grid (order lines)
SELECT c.name AS category, s.status, COUNT(l.order_id) AS lines
FROM categories c CROSS JOIN (SELECT DISTINCT status FROM orders) s
LEFT JOIN products p ON p.category_id = c.category_id
LEFT JOIN v_order_lines l ON l.product_id = p.product_id AND l.status = s.status
GROUP BY c.name, s.status ORDER BY c.name, s.status LIMIT 12;

-- Q39: Products frequently bought together (self-join on order_items)
SELECT p1.name AS product_a, p2.name AS product_b, COUNT(*) AS times_together
FROM order_items a JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON p1.product_id = a.product_id JOIN products p2 ON p2.product_id = b.product_id
GROUP BY a.product_id, b.product_id ORDER BY times_together DESC, product_a LIMIT 5;

-- ############ SECTION F: SUBQUERIES, CTEs, WINDOWS ############

-- Q40: Customers who spent more than the average customer (scalar subquery)
WITH s AS (SELECT customer_id, SUM(line_total) AS total FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY customer_id)
SELECT customer_id, ROUND(total,2) AS total FROM s WHERE total > (SELECT AVG(total) FROM s) ORDER BY total DESC;

-- Q41: Month-over-month revenue growth (LAG)
WITH m AS (SELECT strftime('%Y-%m',order_date) AS month, SUM(line_total) AS rev FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY month)
SELECT month, ROUND(rev,2) AS revenue, ROUND(LAG(rev) OVER (ORDER BY month),2) AS prev_month,
       ROUND(100.0*(rev - LAG(rev) OVER (ORDER BY month)) / NULLIF(LAG(rev) OVER (ORDER BY month),0),1) AS growth_pct
FROM m ORDER BY month LIMIT 8;

-- Q42: Average rating and review count per product (HAVING >= 3 reviews)
SELECT p.name, ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.rating) AS ratings
FROM products p JOIN reviews r ON r.product_id = p.product_id GROUP BY p.product_id HAVING COUNT(r.rating) >= 3 ORDER BY avg_rating DESC, ratings DESC;

-- Q43: Payment method share
SELECT method, COUNT(*) AS payments, ROUND(SUM(amount),2) AS amount, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) AS pct FROM payments GROUP BY method ORDER BY payments DESC;

-- Q44: Cancellation & return rate by quarter
SELECT strftime('%Y',order_date) || '-Q' || ((CAST(strftime('%m',order_date) AS INT)+2)/3) AS quarter,
       COUNT(*) AS orders,
       ROUND(100.0*SUM(status='cancelled')/COUNT(*),1) AS cancelled_pct,
       ROUND(100.0*SUM(status='returned')/COUNT(*),1) AS returned_pct
FROM orders GROUP BY quarter ORDER BY quarter;

-- Q45: Low-stock products that still sell (EXISTS + filter)
SELECT name, stock_qty FROM products p WHERE stock_qty < 70 AND discontinued = 0
AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id) ORDER BY stock_qty;

-- Q46: Payment amount vs computed order total - mismatches (data quality)
WITH t AS (SELECT order_id, ROUND(SUM(line_total),2) AS calc FROM v_order_lines GROUP BY order_id)
SELECT p.order_id, p.amount, t.calc FROM payments p JOIN t ON t.order_id = p.order_id WHERE ABS(p.amount - t.calc) > 0.01;

-- Q47: EXPLAIN - confirm the FK index is used
EXPLAIN QUERY PLAN SELECT * FROM orders WHERE customer_id = 5;
