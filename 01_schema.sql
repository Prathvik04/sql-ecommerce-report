-- =====================================================================
-- SQL E-commerce Report | Week 4 | 01_schema.sql  (DDL + constraints)
-- Dialect: SQLite 3.25+ (notes for MySQL/PostgreSQL are in README.md)
-- =====================================================================
PRAGMA foreign_keys = ON;

DROP VIEW  IF EXISTS v_order_lines;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id  INTEGER PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    phone        TEXT,                              -- nullable on purpose
    city         TEXT,                              -- nullable on purpose
    country      TEXT NOT NULL DEFAULT 'India',
    signup_date  TEXT NOT NULL,                     -- ISO yyyy-mm-dd
    referred_by  INTEGER REFERENCES customers(customer_id) ON DELETE SET NULL
);

CREATE TABLE categories (
    category_id  INTEGER PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    sku           TEXT NOT NULL UNIQUE,
    name          TEXT NOT NULL,
    category_id   INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    unit_price    REAL NOT NULL CHECK (unit_price > 0),
    cost_price    REAL CHECK (cost_price IS NULL OR cost_price >= 0),
    stock_qty     INTEGER NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    discontinued  INTEGER NOT NULL DEFAULT 0 CHECK (discontinued IN (0,1))
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date    TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','shipped','delivered','cancelled','returned')),
    shipped_date  TEXT,                             -- NULL until shipped
    coupon_code   TEXT,                             -- NULL when no coupon
    CHECK (shipped_date IS NULL OR shipped_date >= order_date)
);

CREATE TABLE order_items (
    order_id      INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    REAL NOT NULL CHECK (unit_price > 0),   -- price at time of sale
    discount_pct  REAL CHECK (discount_pct IS NULL OR discount_pct BETWEEN 0 AND 100),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id  INTEGER PRIMARY KEY,
    order_id    INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    method      TEXT NOT NULL CHECK (method IN ('card','upi','netbanking','cod','wallet')),
    amount      REAL NOT NULL CHECK (amount >= 0),
    paid_at     TEXT NOT NULL
);

CREATE TABLE reviews (
    review_id    INTEGER PRIMARY KEY,
    product_id   INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id  INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    rating       INTEGER CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    review_text  TEXT,
    UNIQUE (product_id, customer_id)                -- one review per customer per product
);

-- Indexes on foreign keys / common filters
CREATE INDEX idx_orders_customer  ON orders(customer_id);
CREATE INDEX idx_orders_date      ON orders(order_date);
CREATE INDEX idx_items_product    ON order_items(product_id);
CREATE INDEX idx_products_cat     ON products(category_id);

-- Reusable view: one row per order line with computed net amount
CREATE VIEW v_order_lines AS
SELECT oi.order_id, o.customer_id, o.order_date, o.status,
       oi.product_id, oi.quantity, oi.unit_price,
       COALESCE(oi.discount_pct, 0) AS discount_pct,
       ROUND(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount_pct,0)/100.0), 2) AS line_total
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id;
