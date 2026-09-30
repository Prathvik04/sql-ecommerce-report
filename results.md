# Query results (auto-generated)

## Q1: Customers from Bengaluru
```sql
SELECT customer_id, first_name, last_name, email FROM customers WHERE city = 'Bengaluru' ORDER BY last_name;
```

| customer_id | first_name | last_name | email |
|---|---|---|---|
| 8 | Meera | Das | meera.das@gmail.com |
| 24 | Aditi | Nair | aditi.nair@outlook.com |
| 16 | Pooja | Singh | pooja.singh@gmail.com |

*3 row(s)*

## Q2: Products priced above 1000, most expensive first
```sql
SELECT name, unit_price FROM products WHERE unit_price > 1000 ORDER BY unit_price DESC;
```

| name | unit_price |
|---|---|
| Air Fryer | 5999.0 |
| Running Shoes | 3499.0 |
| Bluetooth Speaker | 3299.0 |
| Wireless Earbuds | 2499.0 |
| Non-stick Pan Set | 2199.0 |
| Power Bank 20000mAh | 1799.0 |
| Building Blocks Set | 1499.0 |
| Electric Kettle | 1299.0 |
| Retro MP3 Player | 1299.0 |

*9 row(s)*

## Q3: Orders placed in Q1 2026
```sql
SELECT order_id, customer_id, order_date, status FROM orders WHERE order_date BETWEEN '2026-01-01' AND '2026-03-31' ORDER BY order_date;
```

| order_id | customer_id | order_date | status |
|---|---|---|---|
| 1 | 15 | 2026-01-09 | delivered |
| 55 | 19 | 2026-01-13 | delivered |
| 48 | 19 | 2026-01-20 | delivered |
| 2 | 15 | 2026-01-24 | delivered |
| 16 | 6 | 2026-01-24 | delivered |
| 5 | 3 | 2026-01-30 | delivered |
| 67 | 11 | 2026-02-26 | shipped |
| 19 | 3 | 2026-03-06 | shipped |
| 30 | 11 | 2026-03-23 | shipped |
| 64 | 10 | 2026-03-26 | delivered |
| 34 | 15 | 2026-03-29 | delivered |
| 69 | 16 | 2026-03-29 | pending |

*12 row(s)*

## Q4: Customers with a Gmail address (pattern matching)
```sql
SELECT first_name, last_name, email FROM customers WHERE email LIKE '%@gmail.com';
```

| first_name | last_name | email |
|---|---|---|
| Aarav | Reddy | aarav.reddy@gmail.com |
| Diya | Iyer | diya.iyer@gmail.com |
| Ananya | Nair | ananya.nair@gmail.com |
| Aditya | Gupta | aditya.gupta@gmail.com |
| Rohan | Kulkarni | rohan.kulkarni@gmail.com |
| Meera | Das | meera.das@gmail.com |
| Sneha | Sharma | sneha.sharma@gmail.com |
| Arjun | Reddy | arjun.reddy@gmail.com |
| Rahul | Patel | rahul.patel@gmail.com |
| Kavya | Nair | kavya.nair@gmail.com |
| Pooja | Singh | pooja.singh@gmail.com |
| Siddharth | Kulkarni | siddharth.kulkarni@gmail.com |
| Varun | Menon | varun.menon@gmail.com |
| Riya | Sharma | riya.sharma@gmail.com |
| Tanvi | Iyer | tanvi.iyer@gmail.com |

*17 row(s)*

## Q5: Orders that are pending or shipped (IN list) and used a coupon
```sql
SELECT order_id, status, coupon_code FROM orders WHERE status IN ('pending','shipped') AND coupon_code IS NOT NULL;
```

| order_id | status | coupon_code |
|---|---|---|
| 19 | shipped | FEST20 |
| 32 | shipped | WELCOME10 |
| 38 | pending | WELCOME10 |
| 39 | shipped | WELCOME10 |
| 67 | shipped | WELCOME10 |

*5 row(s)*

## Q6: Top 5 products by revenue
```sql
SELECT p.name, SUM(l.line_total) AS revenue, SUM(l.quantity) AS units
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY p.product_id, p.name ORDER BY revenue DESC LIMIT 5;
```

| name | revenue | units |
|---|---|---|
| Air Fryer | 87585.4 | 15 |
| Non-stick Pan Set | 47498.4 | 23 |
| Bluetooth Speaker | 39258.1 | 13 |
| Power Bank 20000mAh | 32022.2 | 18 |
| Electric Kettle | 18186.0 | 14 |

*5 row(s)*

## Q7: Top 5 products by units sold
```sql
SELECT p.name, SUM(l.quantity) AS units_sold
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY p.product_id, p.name ORDER BY units_sold DESC, p.name LIMIT 5;
```

| name | units_sold |
|---|---|
| Non-stick Pan Set | 23 |
| Power Bank 20000mAh | 18 |
| Air Fryer | 15 |
| Electric Kettle | 14 |
| Bluetooth Speaker | 13 |

*5 row(s)*

## Q8: Best-selling product in each category (window function)
```sql
WITH rev AS (
  SELECT COALESCE(c.name,'Uncategorised') AS category, p.name AS product, SUM(l.line_total) AS revenue
  FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
  LEFT JOIN categories c ON c.category_id = p.category_id
  WHERE l.status NOT IN ('cancelled','returned') GROUP BY c.name, p.product_id, p.name),
ranked AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn FROM rev)
SELECT category, product, revenue FROM ranked WHERE rn = 1 ORDER BY revenue DESC;
```

| category | product | revenue |
|---|---|---|
| Home & Kitchen | Air Fryer | 87585.4 |
| Electronics | Bluetooth Speaker | 39258.1 |
| Fashion | Running Shoes | 17495.0 |
| Toys | Building Blocks Set | 16489.0 |
| Books | SQL Made Easy | 6955.0 |
| Uncategorised | Gift Card 1000 | 4500.0 |

*6 row(s)*

## Q9: Revenue and share by category
```sql
SELECT COALESCE(c.name,'Uncategorised') AS category,
       ROUND(SUM(l.line_total),2) AS revenue,
       ROUND(100.0 * SUM(l.line_total) / SUM(SUM(l.line_total)) OVER (), 1) AS pct_of_total
FROM v_order_lines l JOIN products p ON p.product_id = l.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY c.name ORDER BY revenue DESC;
```

| category | revenue | pct_of_total |
|---|---|---|
| Home & Kitchen | 153269.8 | 50.0 |
| Electronics | 87440.55 | 28.5 |
| Fashion | 34075.6 | 11.1 |
| Toys | 16489.0 | 5.4 |
| Books | 10506.05 | 3.4 |
| Uncategorised | 4500.0 | 1.5 |

*6 row(s)*

## Q10: Gross margin per product (NULLIF avoids divide-by-zero, NULL cost stays NULL)
```sql
SELECT name, unit_price, cost_price,
       ROUND(100.0 * (unit_price - cost_price) / NULLIF(unit_price,0), 1) AS margin_pct
FROM products ORDER BY margin_pct DESC;
```

| name | unit_price | cost_price | margin_pct |
|---|---|---|---|
| Retro MP3 Player | 1299.0 | 0.0 | 100.0 |
| Smartphone Stand | 499.0 | 180.0 | 63.9 |
| Cotton T-Shirt | 599.0 | 250.0 | 58.3 |
| Leather Wallet | 999.0 | 450.0 | 55.0 |
| SQL Made Easy | 650.0 | 300.0 | 53.8 |
| Data Science Handbook | 899.0 | 450.0 | 49.9 |
| Running Shoes | 3499.0 | 1800.0 | 48.6 |
| Building Blocks Set | 1499.0 | 800.0 | 46.6 |
| Electric Kettle | 1299.0 | 700.0 | 46.1 |
| Non-stick Pan Set | 2199.0 | 1200.0 | 45.4 |
| Wireless Earbuds | 2499.0 | 1400.0 | 44.0 |
| Bluetooth Speaker | 3299.0 | 2000.0 | 39.4 |
| Power Bank 20000mAh | 1799.0 | 1100.0 | 38.9 |
| Air Fryer | 5999.0 | 3800.0 | 36.7 |
| Gift Card 1000 | 1000.0 | NULL | NULL |

*15 row(s)*

## Q11: Products that were never ordered (anti-join)
```sql
SELECT p.product_id, p.name, p.discontinued
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;
```

| product_id | name | discontinued |
|---|---|---|
| 14 | Retro MP3 Player | 1 |

*1 row(s)*

## Q12: Monthly revenue trend
```sql
SELECT strftime('%Y-%m', order_date) AS month, ROUND(SUM(line_total),2) AS revenue, COUNT(DISTINCT order_id) AS orders
FROM v_order_lines WHERE status NOT IN ('cancelled','returned')
GROUP BY month ORDER BY month;
```

| month | revenue | orders |
|---|---|---|
| 2025-01 | 2796.0 | 2 |
| 2025-02 | 8198.0 | 1 |
| 2025-03 | 18595.0 | 1 |
| 2025-04 | 5397.0 | 1 |
| 2025-05 | 18842.0 | 3 |
| 2025-06 | 900.0 | 1 |
| 2025-07 | 4516.0 | 2 |
| 2025-08 | 3418.1 | 1 |
| 2025-09 | 37286.6 | 4 |
| 2025-10 | 10964.65 | 3 |
| 2025-11 | 22086.15 | 4 |
| 2025-12 | 18740.45 | 3 |
| 2026-01 | 22206.15 | 6 |
| 2026-02 | 7596.0 | 1 |
| 2026-03 | 23773.1 | 5 |

*20 row(s)*

## Q13: Top 10 customers by lifetime spend
```sql
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer, ROUND(SUM(l.line_total),2) AS total_spend
FROM customers c JOIN v_order_lines l ON l.customer_id = c.customer_id
WHERE l.status NOT IN ('cancelled','returned')
GROUP BY c.customer_id ORDER BY total_spend DESC LIMIT 10;
```

| customer_id | customer | total_spend |
|---|---|---|
| 6 | Ishita Singh | 41386.95 |
| 3 | Vihaan Patel | 31972.0 |
| 20 | Riya Sharma | 27241.2 |
| 14 | Kavya Nair | 25874.1 |
| 21 | Manav Reddy | 22612.6 |
| 10 | Sneha Sharma | 19007.2 |
| 8 | Meera Das | 18715.2 |
| 9 | Karthik Menon | 16794.1 |
| 13 | Rahul Patel | 16182.75 |
| 11 | Arjun Reddy | 12893.0 |

*10 row(s)*

## Q14: Average order value (AOV) per customer
```sql
WITH order_totals AS (
  SELECT order_id, customer_id, SUM(line_total) AS order_total FROM v_order_lines
  WHERE status NOT IN ('cancelled','returned') GROUP BY order_id, customer_id)
SELECT customer_id, COUNT(*) AS orders, ROUND(AVG(order_total),2) AS aov, ROUND(MAX(order_total),2) AS biggest_order
FROM order_totals GROUP BY customer_id ORDER BY aov DESC LIMIT 10;
```

| customer_id | orders | aov | biggest_order |
|---|---|---|---|
| 14 | 2 | 12937.05 | 24114.9 |
| 6 | 4 | 10346.74 | 12673.8 |
| 20 | 3 | 9080.4 | 18595.0 |
| 13 | 2 | 8091.38 | 12444.45 |
| 7 | 1 | 8070.05 | 8070.05 |
| 3 | 5 | 6394.4 | 14095.0 |
| 10 | 3 | 6335.73 | 10094.1 |
| 8 | 3 | 6238.4 | 12250.05 |
| 21 | 4 | 5653.15 | 11998.0 |
| 9 | 3 | 5598.03 | 11398.1 |

*10 row(s)*

## Q15: Customer tiers with CASE
```sql
WITH spend AS (
  SELECT c.customer_id, c.first_name, COALESCE(SUM(l.line_total),0) AS total
  FROM customers c LEFT JOIN v_order_lines l ON l.customer_id = c.customer_id AND l.status NOT IN ('cancelled','returned')
  GROUP BY c.customer_id)
SELECT CASE WHEN total >= 20000 THEN 'Gold' WHEN total >= 8000 THEN 'Silver' WHEN total > 0 THEN 'Bronze' ELSE 'No purchases' END AS tier,
       COUNT(*) AS customers, ROUND(SUM(total),2) AS tier_revenue
FROM spend GROUP BY tier ORDER BY tier_revenue DESC;
```

| tier | customers | tier_revenue |
|---|---|---|
| Gold | 5 | 149086.85 |
| Silver | 11 | 142450.15 |
| Bronze | 3 | 14744.0 |
| No purchases | 6 | 0.0 |

*4 row(s)*

## Q16: Customers who never placed an order
```sql
SELECT c.customer_id, c.first_name, c.last_name, c.signup_date
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id WHERE o.order_id IS NULL;
```

| customer_id | first_name | last_name | signup_date |
|---|---|---|---|
| 12 | Priya | Iyer | 2024-10-11 |
| 22 | Tanvi | Iyer | 2024-03-12 |
| 23 | Yash | Patel | 2024-08-21 |
| 24 | Aditi | Nair | 2024-03-22 |
| 25 | Farhan | Gupta | 2025-01-24 |

*5 row(s)*

## Q17: Repeat customers (HAVING)
```sql
SELECT customer_id, COUNT(*) AS orders_placed, MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM orders GROUP BY customer_id HAVING COUNT(*) >= 4 ORDER BY orders_placed DESC;
```

| customer_id | orders_placed | first_order | last_order |
|---|---|---|---|
| 19 | 6 | 2025-01-22 | 2026-08-14 |
| 3 | 5 | 2025-05-22 | 2026-03-06 |
| 13 | 5 | 2025-10-02 | 2026-08-22 |
| 15 | 5 | 2025-06-12 | 2026-03-29 |
| 21 | 5 | 2025-07-22 | 2026-07-08 |
| 6 | 4 | 2025-02-22 | 2026-08-23 |
| 8 | 4 | 2025-01-25 | 2026-07-29 |
| 9 | 4 | 2025-02-16 | 2026-07-24 |
| 17 | 4 | 2025-04-19 | 2026-07-06 |
| 20 | 4 | 2025-03-16 | 2026-06-26 |

*10 row(s)*

## Q18: Revenue by city (NULL city shown as 'Unknown')
```sql
SELECT COALESCE(c.city,'Unknown') AS city, COUNT(DISTINCT c.customer_id) AS customers, ROUND(SUM(l.line_total),2) AS revenue
FROM customers c JOIN v_order_lines l ON l.customer_id = c.customer_id
WHERE l.status NOT IN ('cancelled','returned') GROUP BY c.city ORDER BY revenue DESC;
```

| city | customers | revenue |
|---|---|---|
| Kolkata | 2 | 67261.05 |
| Chennai | 3 | 57684.65 |
| Pune | 3 | 46692.35 |
| Delhi | 3 | 31719.3 |
| Mumbai | 3 | 29159.2 |
| Bengaluru | 2 | 27262.2 |
| Hyderabad | 1 | 27241.2 |
| Unknown | 2 | 19261.05 |

*8 row(s)*

## Q19: Running total of spend for customer 3 (window)
```sql
WITH o AS (SELECT order_id, order_date, SUM(line_total) AS amt FROM v_order_lines
           WHERE customer_id = 3 AND status NOT IN ('cancelled','returned') GROUP BY order_id, order_date)
SELECT order_date, order_id, ROUND(amt,2) AS order_amt,
       ROUND(SUM(amt) OVER (ORDER BY order_date, order_id),2) AS running_total FROM o ORDER BY order_date, order_id;
```

| order_date | order_id | order_amt | running_total |
|---|---|---|---|
| 2025-05-22 | 40 | 12996.0 | 12996.0 |
| 2025-07-10 | 18 | 2997.0 | 15993.0 |
| 2025-09-12 | 60 | 14095.0 | 30088.0 |
| 2026-01-30 | 5 | 1299.0 | 31387.0 |
| 2026-03-06 | 19 | 585.0 | 31972.0 |

*5 row(s)*

## Q20: Customer ranking with RANK and DENSE_RANK
```sql
WITH s AS (SELECT customer_id, SUM(line_total) AS total FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY customer_id)
SELECT customer_id, ROUND(total,2) AS total, RANK() OVER (ORDER BY total DESC) AS rnk, DENSE_RANK() OVER (ORDER BY total DESC) AS dense_rnk,
       NTILE(4) OVER (ORDER BY total DESC) AS quartile
FROM s ORDER BY rnk LIMIT 10;
```

| customer_id | total | rnk | dense_rnk | quartile |
|---|---|---|---|---|
| 6 | 41386.95 | 1 | 1 | 1 |
| 3 | 31972.0 | 2 | 2 | 1 |
| 20 | 27241.2 | 3 | 3 | 1 |
| 14 | 25874.1 | 4 | 4 | 1 |
| 21 | 22612.6 | 5 | 5 | 1 |
| 10 | 19007.2 | 6 | 6 | 2 |
| 8 | 18715.2 | 7 | 7 | 2 |
| 9 | 16794.1 | 8 | 8 | 2 |
| 13 | 16182.75 | 9 | 9 | 2 |
| 11 | 12893.0 | 10 | 10 | 2 |

*10 row(s)*

## Q21: Customers missing a phone number (IS NULL, never = NULL)
```sql
SELECT customer_id, first_name, last_name FROM customers WHERE phone IS NULL;
```

| customer_id | first_name | last_name |
|---|---|---|
| 4 | Ananya | Nair |
| 8 | Meera | Das |
| 12 | Priya | Iyer |
| 16 | Pooja | Singh |
| 20 | Riya | Sharma |
| 24 | Aditi | Nair |

*6 row(s)*

## Q22: COALESCE to display friendly text
```sql
SELECT customer_id, first_name, COALESCE(phone,'not provided') AS phone, COALESCE(city,'Unknown') AS city FROM customers LIMIT 10;
```

| customer_id | first_name | phone | city |
|---|---|---|---|
| 1 | Aarav | 9895822412 | Mumbai |
| 2 | Diya | 9813356886 | Delhi |
| 3 | Vihaan | 9842868828 | Chennai |
| 4 | Ananya | not provided | Hyderabad |
| 5 | Aditya | 9823756669 | Pune |
| 6 | Ishita | 9821668732 | Kolkata |
| 7 | Rohan | 9813999315 | Unknown |
| 8 | Meera | not provided | Bengaluru |
| 9 | Karthik | 9890801586 | Mumbai |
| 10 | Sneha | 9836687537 | Delhi |

*10 row(s)*

## Q23: COUNT(*) vs COUNT(column) - NULLs are skipped by COUNT(col)
```sql
SELECT COUNT(*) AS all_customers, COUNT(phone) AS with_phone, COUNT(city) AS with_city, COUNT(*) - COUNT(phone) AS missing_phone FROM customers;
```

| all_customers | with_phone | with_city | missing_phone |
|---|---|---|---|
| 25 | 19 | 22 | 6 |

*1 row(s)*

## Q24: AVG ignores NULL; compare with treating NULL as 0
```sql
SELECT ROUND(AVG(rating),2) AS avg_ignoring_null, ROUND(AVG(COALESCE(rating,0)),2) AS avg_null_as_zero,
       COUNT(*) AS reviews, COUNT(rating) AS rated FROM reviews;
```

| avg_ignoring_null | avg_null_as_zero | reviews | rated |
|---|---|---|---|
| 3.63 | 3.21 | 43 | 38 |

*1 row(s)*

## Q25: Orders not yet shipped (excluding cancelled)
```sql
SELECT order_id, customer_id, order_date, status FROM orders WHERE shipped_date IS NULL AND status <> 'cancelled' ORDER BY order_date;
```

| order_id | customer_id | order_date | status |
|---|---|---|---|
| 38 | 15 | 2025-06-12 | pending |
| 69 | 16 | 2026-03-29 | pending |

*2 row(s)*

## Q26: Average days to ship (NULL shipped_date rows are ignored automatically)
```sql
SELECT ROUND(AVG(julianday(shipped_date) - julianday(order_date)),2) AS avg_days_to_ship, COUNT(shipped_date) AS shipped_orders, COUNT(*) - COUNT(shipped_date) AS not_shipped FROM orders;
```

| avg_days_to_ship | shipped_orders | not_shipped |
|---|---|---|
| 3.25 | 56 | 14 |

*1 row(s)*

## Q27: NOT IN trap vs NOT EXISTS: products.category_id contains a NULL
```sql
SELECT 'NOT IN' AS method, COUNT(*) AS empty_categories FROM categories WHERE category_id NOT IN (SELECT category_id FROM products)
UNION ALL
SELECT 'NOT EXISTS', COUNT(*) FROM categories c WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.category_id = c.category_id);
```

| method | empty_categories |
|---|---|
| NOT IN | 0 |
| NOT EXISTS | 1 |

*2 row(s)*

## Q28: Sort NULLs last
```sql
SELECT order_id, status, shipped_date FROM orders ORDER BY shipped_date IS NULL, shipped_date DESC LIMIT 10;
```

| order_id | status | shipped_date |
|---|---|---|
| 66 | delivered | 2026-08-27 |
| 41 | returned | 2026-08-23 |
| 12 | delivered | 2026-08-18 |
| 61 | shipped | 2026-08-11 |
| 47 | returned | 2026-08-05 |
| 4 | delivered | 2026-08-03 |
| 53 | delivered | 2026-07-26 |
| 25 | delivered | 2026-07-22 |
| 17 | delivered | 2026-07-13 |
| 31 | shipped | 2026-07-08 |

*10 row(s)*

## Q29: Coupon usage with NULL bucket labelled
```sql
SELECT COALESCE(coupon_code,'NO COUPON') AS coupon, COUNT(*) AS orders FROM orders GROUP BY coupon_code ORDER BY orders DESC;
```

| coupon | orders |
|---|---|
| NO COUPON | 48 |
| WELCOME10 | 13 |
| FEST20 | 9 |

*3 row(s)*

## Q30: NULL discount treated as 0 vs. discounted lines
```sql
SELECT CASE WHEN discount_pct IS NULL THEN 'no discount recorded' WHEN discount_pct = 0 THEN '0%' ELSE 'discounted' END AS bucket,
       COUNT(*) AS lines FROM order_items GROUP BY bucket;
```

| bucket | lines |
|---|---|
| 0% | 14 |
| discounted | 32 |
| no discount recorded | 61 |

*3 row(s)*

## Q31: INNER JOIN - full order detail
```sql
SELECT o.order_id, c.first_name, p.name AS product, oi.quantity, oi.unit_price
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id LIMIT 10;
```

| order_id | first_name | product | quantity | unit_price |
|---|---|---|---|---|
| 1 | Nikhil | Building Blocks Set | 3 | 1499.0 |
| 1 | Nikhil | Cotton T-Shirt | 3 | 599.0 |
| 2 | Nikhil | Gift Card 1000 | 1 | 1000.0 |
| 3 | Rahul | Non-stick Pan Set | 2 | 2199.0 |
| 4 | Meera | Air Fryer | 1 | 5999.0 |
| 4 | Meera | Data Science Handbook | 1 | 899.0 |
| 4 | Meera | Power Bank 20000mAh | 3 | 1799.0 |
| 5 | Vihaan | Electric Kettle | 1 | 1299.0 |
| 6 | Karthik | Building Blocks Set | 3 | 1499.0 |
| 7 | Siddharth | Electric Kettle | 1 | 1299.0 |

*10 row(s)*

## Q32: LEFT JOIN - every category with product count (empty categories included)
```sql
SELECT c.name AS category, COUNT(p.product_id) AS products FROM categories c LEFT JOIN products p ON p.category_id = c.category_id GROUP BY c.category_id ORDER BY products DESC;
```

| category | products |
|---|---|
| Electronics | 5 |
| Home & Kitchen | 3 |
| Fashion | 3 |
| Books | 2 |
| Toys | 1 |
| Garden | 0 |

*6 row(s)*

## Q33: LEFT JOIN + COALESCE - products without a category
```sql
SELECT p.name, COALESCE(c.name,'Uncategorised') AS category FROM products p LEFT JOIN categories c ON c.category_id = p.category_id WHERE c.category_id IS NULL;
```

| name | category |
|---|---|
| Gift Card 1000 | Uncategorised |

*1 row(s)*

## Q34: SELF JOIN - who referred whom
```sql
SELECT r.first_name || ' ' || r.last_name AS customer, COALESCE(ref.first_name || ' ' || ref.last_name,'(organic)') AS referred_by
FROM customers r LEFT JOIN customers ref ON ref.customer_id = r.referred_by ORDER BY r.customer_id LIMIT 12;
```

| customer | referred_by |
|---|---|
| Aarav Reddy | (organic) |
| Diya Iyer | (organic) |
| Vihaan Patel | (organic) |
| Ananya Nair | (organic) |
| Aditya Gupta | (organic) |
| Ishita Singh | Aarav Reddy |
| Rohan Kulkarni | Diya Iyer |
| Meera Das | Aditya Gupta |
| Karthik Menon | Aditya Gupta |
| Sneha Sharma | Ananya Nair |
| Arjun Reddy | Aditya Gupta |
| Priya Iyer | Aarav Reddy |

*12 row(s)*

## Q35: Referrers ranked by how many customers they brought in
```sql
SELECT ref.first_name || ' ' || ref.last_name AS referrer, COUNT(*) AS referrals
FROM customers c JOIN customers ref ON ref.customer_id = c.referred_by GROUP BY ref.customer_id ORDER BY referrals DESC;
```

| referrer | referrals |
|---|---|
| Aditya Gupta | 6 |
| Aarav Reddy | 5 |
| Ananya Nair | 3 |
| Vihaan Patel | 3 |
| Diya Iyer | 3 |

*5 row(s)*

## Q36: Orders with no payment record (shipped/delivered but unpaid data gap)
```sql
SELECT o.order_id, o.status, o.order_date FROM orders o LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL AND o.status IN ('shipped','delivered') ORDER BY o.order_id;
```

| order_id | status | order_date |
|---|---|---|
| 16 | delivered | 2026-01-24 |
| 67 | shipped | 2026-02-26 |

*2 row(s)*

## Q37: FULL OUTER JOIN emulation (portable): products vs reviews
```sql
SELECT p.name, r.review_id FROM products p LEFT JOIN reviews r ON r.product_id = p.product_id WHERE r.review_id IS NULL
UNION
SELECT p.name, r.review_id FROM reviews r LEFT JOIN products p ON p.product_id = r.product_id WHERE p.product_id IS NULL;
```

| name | review_id |
|---|---|
| Gift Card 1000 | NULL |
| Retro MP3 Player | NULL |

*2 row(s)*

## Q38: CROSS JOIN - category x status grid (order lines)
```sql
SELECT c.name AS category, s.status, COUNT(l.order_id) AS lines
FROM categories c CROSS JOIN (SELECT DISTINCT status FROM orders) s
LEFT JOIN products p ON p.category_id = c.category_id
LEFT JOIN v_order_lines l ON l.product_id = p.product_id AND l.status = s.status
GROUP BY c.name, s.status ORDER BY c.name, s.status LIMIT 12;
```

| category | status | lines |
|---|---|---|
| Books | cancelled | 2 |
| Books | delivered | 8 |
| Books | pending | 0 |
| Books | returned | 1 |
| Books | shipped | 2 |
| Electronics | cancelled | 7 |
| Electronics | delivered | 16 |
| Electronics | pending | 1 |
| Electronics | returned | 3 |
| Electronics | shipped | 5 |
| Fashion | cancelled | 2 |
| Fashion | delivered | 9 |

*12 row(s)*

## Q39: Products frequently bought together (self-join on order_items)
```sql
SELECT p1.name AS product_a, p2.name AS product_b, COUNT(*) AS times_together
FROM order_items a JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON p1.product_id = a.product_id JOIN products p2 ON p2.product_id = b.product_id
GROUP BY a.product_id, b.product_id ORDER BY times_together DESC, product_a LIMIT 5;
```

| product_a | product_b | times_together |
|---|---|---|
| Air Fryer | Non-stick Pan Set | 2 |
| Bluetooth Speaker | Power Bank 20000mAh | 2 |
| Non-stick Pan Set | Electric Kettle | 2 |
| Power Bank 20000mAh | Non-stick Pan Set | 2 |
| Power Bank 20000mAh | Leather Wallet | 2 |

*5 row(s)*

## Q40: Customers who spent more than the average customer (scalar subquery)
```sql
WITH s AS (SELECT customer_id, SUM(line_total) AS total FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY customer_id)
SELECT customer_id, ROUND(total,2) AS total FROM s WHERE total > (SELECT AVG(total) FROM s) ORDER BY total DESC;
```

| customer_id | total |
|---|---|
| 6 | 41386.95 |
| 3 | 31972.0 |
| 20 | 27241.2 |
| 14 | 25874.1 |
| 21 | 22612.6 |
| 10 | 19007.2 |
| 8 | 18715.2 |
| 9 | 16794.1 |
| 13 | 16182.75 |

*9 row(s)*

## Q41: Month-over-month revenue growth (LAG)
```sql
WITH m AS (SELECT strftime('%Y-%m',order_date) AS month, SUM(line_total) AS rev FROM v_order_lines WHERE status NOT IN ('cancelled','returned') GROUP BY month)
SELECT month, ROUND(rev,2) AS revenue, ROUND(LAG(rev) OVER (ORDER BY month),2) AS prev_month,
       ROUND(100.0*(rev - LAG(rev) OVER (ORDER BY month)) / NULLIF(LAG(rev) OVER (ORDER BY month),0),1) AS growth_pct
FROM m ORDER BY month LIMIT 8;
```

| month | revenue | prev_month | growth_pct |
|---|---|---|---|
| 2025-01 | 2796.0 | NULL | NULL |
| 2025-02 | 8198.0 | 2796.0 | 193.2 |
| 2025-03 | 18595.0 | 8198.0 | 126.8 |
| 2025-04 | 5397.0 | 18595.0 | -71.0 |
| 2025-05 | 18842.0 | 5397.0 | 249.1 |
| 2025-06 | 900.0 | 18842.0 | -95.2 |
| 2025-07 | 4516.0 | 900.0 | 401.8 |
| 2025-08 | 3418.1 | 4516.0 | -24.3 |

*8 row(s)*

## Q42: Average rating and review count per product (HAVING >= 3 reviews)
```sql
SELECT p.name, ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.rating) AS ratings
FROM products p JOIN reviews r ON r.product_id = p.product_id GROUP BY p.product_id HAVING COUNT(r.rating) >= 3 ORDER BY avg_rating DESC, ratings DESC;
```

| name | avg_rating | ratings |
|---|---|---|
| Leather Wallet | 4.0 | 5 |
| Non-stick Pan Set | 4.0 | 4 |
| Cotton T-Shirt | 3.8 | 5 |
| Air Fryer | 3.75 | 4 |
| Building Blocks Set | 3.67 | 6 |
| Bluetooth Speaker | 3.67 | 3 |
| SQL Made Easy | 2.33 | 3 |

*7 row(s)*

## Q43: Payment method share
```sql
SELECT method, COUNT(*) AS payments, ROUND(SUM(amount),2) AS amount, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),1) AS pct FROM payments GROUP BY method ORDER BY payments DESC;
```

| method | payments | amount | pct |
|---|---|---|---|
| upi | 21 | 131038.3 | 38.9 |
| wallet | 11 | 48638.7 | 20.4 |
| netbanking | 10 | 78185.55 | 18.5 |
| cod | 9 | 43560.45 | 16.7 |
| card | 3 | 8398.0 | 5.6 |

*5 row(s)*

## Q44: Cancellation & return rate by quarter
```sql
SELECT strftime('%Y',order_date) || '-Q' || ((CAST(strftime('%m',order_date) AS INT)+2)/3) AS quarter,
       COUNT(*) AS orders,
       ROUND(100.0*SUM(status='cancelled')/COUNT(*),1) AS cancelled_pct,
       ROUND(100.0*SUM(status='returned')/COUNT(*),1) AS returned_pct
FROM orders GROUP BY quarter ORDER BY quarter;
```

| quarter | orders | cancelled_pct | returned_pct |
|---|---|---|---|
| 2025-Q1 | 7 | 14.3 | 28.6 |
| 2025-Q2 | 7 | 28.6 | 0.0 |
| 2025-Q3 | 9 | 22.2 | 0.0 |
| 2025-Q4 | 13 | 15.4 | 7.7 |
| 2026-Q1 | 12 | 0.0 | 0.0 |
| 2026-Q2 | 9 | 22.2 | 0.0 |
| 2026-Q3 | 13 | 23.1 | 15.4 |

*7 row(s)*

## Q45: Low-stock products that still sell (EXISTS + filter)
```sql
SELECT name, stock_qty FROM products p WHERE stock_qty < 70 AND discontinued = 0
AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id) ORDER BY stock_qty;
```

| name | stock_qty |
|---|---|
| Air Fryer | 40 |
| Building Blocks Set | 55 |
| Bluetooth Speaker | 60 |
| Leather Wallet | 65 |

*4 row(s)*

## Q46: Payment amount vs computed order total - mismatches (data quality)
```sql
WITH t AS (SELECT order_id, ROUND(SUM(line_total),2) AS calc FROM v_order_lines GROUP BY order_id)
SELECT p.order_id, p.amount, t.calc FROM payments p JOIN t ON t.order_id = p.order_id WHERE ABS(p.amount - t.calc) > 0.01;
```

| order_id | amount | calc |
|---|---|---|

*0 row(s)*

## Q47: EXPLAIN - confirm the FK index is used
```sql
EXPLAIN QUERY PLAN SELECT * FROM orders WHERE customer_id = 5;
```

| id | parent | notused | detail |
|---|---|---|---|
| 3 | 0 | 61 | SEARCH orders USING INDEX idx_orders_customer (customer_id=?) |

*1 row(s)*
