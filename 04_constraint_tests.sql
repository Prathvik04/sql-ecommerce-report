-- =====================================================================
-- 04_constraint_tests.sql : every statement below MUST FAIL (proves DDL constraints work)
-- Each block is separated by a line "-- T:" and executed independently.
-- =====================================================================
-- T: UNIQUE email
INSERT INTO customers (first_name,last_name,email,signup_date) VALUES ('A','B','aarav.reddy@gmail.com','2025-01-01');
-- T: NOT NULL first_name
INSERT INTO customers (last_name,email,signup_date) VALUES ('B','x@y.com','2025-01-01');
-- T: CHECK email format
INSERT INTO customers (first_name,last_name,email,signup_date) VALUES ('A','B','not-an-email','2025-01-01');
-- T: CHECK price > 0
INSERT INTO products (sku,name,unit_price) VALUES ('X-1','Bad',-5);
-- T: CHECK stock >= 0
INSERT INTO products (sku,name,unit_price,stock_qty) VALUES ('X-2','Bad',5,-1);
-- T: CHECK status list
INSERT INTO orders (customer_id,order_date,status) VALUES (1,'2026-01-01','lost');
-- T: CHECK shipped_date >= order_date
INSERT INTO orders (customer_id,order_date,status,shipped_date) VALUES (1,'2026-01-10','shipped','2026-01-01');
-- T: FOREIGN KEY customer must exist
INSERT INTO orders (customer_id,order_date) VALUES (9999,'2026-01-01');
-- T: composite PRIMARY KEY (order_id, product_id)
INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES (1,(SELECT product_id FROM order_items WHERE order_id=1 LIMIT 1),1,100);
-- T: CHECK quantity > 0
INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES (1,14,0,100);
-- T: CHECK discount 0-100
INSERT INTO order_items (order_id,product_id,quantity,unit_price,discount_pct) VALUES (1,14,1,100,150);
-- T: CHECK payment method
INSERT INTO payments (order_id,method,amount,paid_at) VALUES (1,'bitcoin',10,'2026-01-01');
-- T: CHECK rating 1-5
INSERT INTO reviews (product_id,customer_id,rating) VALUES (14,1,9);
-- T: UNIQUE(product_id, customer_id)
INSERT INTO reviews (product_id,customer_id,rating) SELECT product_id,customer_id,3 FROM reviews LIMIT 1;
-- T: ON DELETE RESTRICT (customer with orders cannot be deleted)
DELETE FROM customers WHERE customer_id = 1;
