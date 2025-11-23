-- Simple e-commerce database

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Tables

CREATE TABLE customers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  street VARCHAR(100),
  city VARCHAR(50),
  state VARCHAR(50),
  postal_code VARCHAR(20),
  country VARCHAR(50) DEFAULT 'India',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX idx_customers_email ON customers(email);

CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_categories_name ON categories(name);

CREATE TABLE products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  sku VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category_id_ ON products(category_id);

CREATE TABLE orders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','paid','shipped','cancelled') NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  shipping_address VARCHAR(255),
  billing_address VARCHAR(255),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);

CREATE TABLE order_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  line_total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Triggers and stored procedures

DELIMITER $$

DROP TRIGGER IF EXISTS trg_order_items_ai_stock $$
CREATE TRIGGER trg_order_items_ai_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock = stock - NEW.quantity
  WHERE id = NEW.product_id;

  UPDATE orders o
  JOIN (
    SELECT order_id, SUM(line_total) AS total
    FROM order_items
    WHERE order_id = NEW.order_id
    GROUP BY order_id
  ) t ON o.id = t.order_id
  SET o.total_amount = t.total;
END $$

DROP TRIGGER IF EXISTS trg_order_items_au_stock $$
CREATE TRIGGER trg_order_items_au_stock
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock = stock + (OLD.quantity - NEW.quantity)
  WHERE id = NEW.product_id;

  UPDATE orders o
  JOIN (
    SELECT order_id, SUM(line_total) AS total
    FROM order_items
    WHERE order_id = NEW.order_id
    GROUP BY order_id
  ) t ON o.id = t.order_id
  SET o.total_amount = t.total;
END $$

DROP TRIGGER IF EXISTS trg_order_items_ad_stock $$
CREATE TRIGGER trg_order_items_ad_stock
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
  UPDATE products
  SET stock = stock + OLD.quantity
  WHERE id = OLD.product_id;

  UPDATE orders o
  LEFT JOIN (
    SELECT order_id, SUM(line_total) AS total
    FROM order_items
    WHERE order_id = OLD.order_id
    GROUP BY order_id
  ) t ON o.id = t.order_id
  SET o.total_amount = IFNULL(t.total, 0)
  WHERE o.id = OLD.order_id;
END $$

-- Stored procedure: customer order summary

DROP PROCEDURE IF EXISTS get_customer_order_summary $$
CREATE PROCEDURE get_customer_order_summary(IN p_customer_id INT UNSIGNED)
BEGIN
  SELECT
    o.id AS order_id,
    o.order_date,
    o.status,
    o.total_amount
  FROM orders o
  WHERE o.customer_id = p_customer_id
  ORDER BY o.order_date DESC;
END $$

-- Stored procedure: top customers by total spend

DROP PROCEDURE IF EXISTS get_top_customers $$
CREATE PROCEDURE get_top_customers(IN p_limit INT)
BEGIN
  SELECT
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(o.id) AS orders_count,
    IFNULL(SUM(o.total_amount), 0) AS total_spent
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.id
  GROUP BY c.id, c.first_name, c.last_name, c.email
  ORDER BY total_spent DESC
  LIMIT p_limit;
END $$

-- Simple reporting view

DROP VIEW IF EXISTS customer_order_totals $$
CREATE VIEW customer_order_totals AS
SELECT
  c.id AS customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COUNT(o.id) AS orders_count,
  IFNULL(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.first_name, c.last_name $$

DELIMITER ;

-- Sample data

INSERT INTO categories (id, name, description) VALUES
(1, 'Electronics', 'Computers, accessories and gadgets'),
(2, 'Home & Kitchen', 'Daily home and kitchen items'),
(3, 'Books', 'Fiction and non-fiction books'),
(4, 'Clothing', 'Men and women clothing'),
(5, 'Sports & Outdoors', 'Sports gear and outdoor items'),
(6, 'Beauty & Personal Care', 'Personal care and grooming'),
(7, 'Groceries', 'Daily groceries'),
(8, 'Mobile Accessories', 'Covers, cables and more'),
(9, 'Office Supplies', 'Stationery and supplies'),
(10, 'Toys & Games', 'Kids toys and games');

INSERT INTO customers
(id, first_name, last_name, email, phone, street, city, state, postal_code, country)
VALUES
(1, 'Rahul', 'Desai', 'rahul.desai@example.com', '+91-9876543101', '201 Lake View Road', 'Mumbai', 'Maharashtra', '400701', 'India'),
(2, 'Priya', 'Kulkarni', 'priya.kulkarni@example.com', '+91-9876543102', '12 FC Road', 'Pune', 'Maharashtra', '411004', 'India'),
(3, 'Aman', 'Verma', 'aman.verma@example.com', '+91-9876543103', '8 Waghbil Naka', 'Thane', 'Maharashtra', '400607', 'India'),
(4, 'Sneha', 'Nair', 'sneha.nair@example.com', '+91-9876543104', '34 MG Road', 'Bengaluru', 'Karnataka', '560001', 'India'),
(5, 'Karan', 'Singh', 'karan.singh@example.com', '+91-9876543105', '21 Ring Road', 'New Delhi', 'Delhi', '110001', 'India'),
(6, 'Neha', 'Patel', 'neha.patel@example.com', '+91-9876543106', '5 CG Road', 'Ahmedabad', 'Gujarat', '380009', 'India'),
(7, 'Arjun', 'Mehta', 'arjun.mehta@example.com', '+91-9876543107', '17 Palm Beach Road', 'Navi Mumbai', 'Maharashtra', '400706', 'India'),
(8, 'Riya', 'Sharma', 'riya.sharma@example.com', '+91-9876543108', '3 MI Road', 'Jaipur', 'Rajasthan', '302001', 'India'),
(9, 'Varun', 'Iyer', 'varun.iyer@example.com', '+91-9876543109', '9 T Nagar', 'Chennai', 'Tamil Nadu', '600017', 'India'),
(10, 'Pooja', 'Joshi', 'pooja.joshi@example.com', '+91-9876543110', '44 Wardhaman Nagar', 'Nagpur', 'Maharashtra', '440008', 'India'),
(11, 'Sandeep', 'Rao', 'sandeep.rao@example.com', '+91-9876543111', '11 Banjara Hills', 'Hyderabad', 'Telangana', '500034', 'India'),
(12, 'Ananya', 'Gupta', 'ananya.gupta@example.com', '+91-9876543112', '27 Sector 18', 'Noida', 'Uttar Pradesh', '201301', 'India');

INSERT INTO products
(id, category_id, name, sku, description, price, stock)
VALUES
(1, 1, 'Wireless Mouse MX100', 'WMX100', '2.4GHz wireless mouse with USB receiver', 799.00, 50),
(2, 1, 'Mechanical Keyboard K220', 'MK220', 'Mechanical keyboard with blue switches', 2499.00, 40),
(3, 1, '27 Inch Monitor ProView', 'MON27PV', '27 inch full HD IPS monitor', 12499.00, 25),
(4, 8, 'USB-C Charging Cable 1.5m', 'USBC15', 'USB-C cable, fast charging, 1.5 meter', 399.00, 60),
(5, 1, 'Bluetooth Earbuds AirBeat', 'BBEAIR', 'True wireless earbuds with mic', 1999.00, 35),
(6, 6, 'Stainless Steel Water Bottle 1L', 'SSB1L', 'Insulated water bottle 1 litre', 699.00, 80),
(7, 2, 'Non-stick Frying Pan 24cm', 'PAN24NS', 'Non-stick frying pan with lid', 1199.00, 30),
(8, 7, 'Organic Green Tea 100 Bags', 'GRNTEA100', 'Box of 100 green tea bags', 349.00, 70),
(9, 5, 'Running Shoes RoadRunner', 'RSHRR', 'Lightweight running shoes', 2999.00, 40),
(10, 4, 'Cotton T-Shirt Classic White M', 'TSHIRTWHM', '100% cotton t-shirt, white, size M', 599.00, 90),
(11, 9, 'Desk Notebook A5 Ruled 200 Pages', 'NBKA5R200', 'A5 notebook with ruled pages', 249.00, 120),
(12, 9, 'Ballpoint Pens SmoothFlow Pack of 10', 'PEN10SF', 'Pack of 10 smooth ball pens', 149.00, 150),
(13, 10, 'Kids Building Blocks Set 120 pcs', 'TOYBLK120', 'Colourful blocks set for kids', 899.00, 45),
(14, 3, 'Novel The Silent River (Paperback)', 'BOOKSRIV', 'Fiction novel in paperback', 349.00, 100),
(15, 6, 'Face Wash Gentle Clean 100ml', 'FWASH100', 'Gentle face wash 100 ml', 249.00, 60),
(16, 6, 'Shampoo Anti-Dandruff 200ml', 'SHAMP200', 'Anti-dandruff shampoo 200 ml', 349.00, 55),
(17, 8, 'Smartphone Case Galaxy X Clear', 'CASEGXCLR', 'Clear case for Galaxy X', 499.00, 75),
(18, 8, 'Power Bank 10000mAh LiteCharge', 'PBANK10K', '10000mAh compact power bank', 1599.00, 50);

INSERT INTO orders
(id, customer_id, order_date, status, total_amount, shipping_address, billing_address)
VALUES
(1, 1, '2025-06-10 10:15:00', 'paid', 3596.00,
 '201 Lake View Road, Mumbai, Maharashtra 400701, India',
 '201 Lake View Road, Mumbai, Maharashtra 400701, India'),
(2, 3, '2025-07-05 14:30:00', 'paid', 14998.00,
 '8 Waghbil Naka, Thane, Maharashtra 400607, India',
 '8 Waghbil Naka, Thane, Maharashtra 400607, India'),
(3, 4, '2025-08-21 09:45:00', 'shipped', 4197.00,
 '34 MG Road, Bengaluru, Karnataka 560001, India',
 '34 MG Road, Bengaluru, Karnataka 560001, India'),
(4, 7, '2025-09-02 18:05:00', 'paid', 2596.00,
 '17 Palm Beach Road, Navi Mumbai, Maharashtra 400706, India',
 '17 Palm Beach Road, Navi Mumbai, Maharashtra 400706, India'),
(5, 2, '2025-10-11 11:20:00', 'pending', 3297.00,
 '12 FC Road, Pune, Maharashtra 411004, India',
 '12 FC Road, Pune, Maharashtra 411004, India'),
(6, 9, '2025-10-20 16:10:00', 'paid', 1743.00,
 '9 T Nagar, Chennai, Tamil Nadu 600017, India',
 '9 T Nagar, Chennai, Tamil Nadu 600017, India'),
(7, 1, '2025-11-05 20:40:00', 'shipped', 4745.00,
 '201 Lake View Road, Mumbai, Maharashtra 400701, India',
 '201 Lake View Road, Mumbai, Maharashtra 400701, India');

INSERT INTO order_items
(id, order_id, product_id, quantity, unit_price, line_total)
VALUES
(1, 1, 1, 2, 799.00, 1598.00),
(2, 1, 4, 1, 399.00, 399.00),
(3, 1, 18, 1, 1599.00, 1599.00),

(4, 2, 3, 1, 12499.00, 12499.00),
(5, 2, 2, 1, 2499.00, 2499.00),

(6, 3, 9, 1, 2999.00, 2999.00),
(7, 3, 10, 2, 599.00, 1198.00),

(8, 4, 6, 1, 699.00, 699.00),
(9, 4, 7, 1, 1199.00, 1199.00),
(10, 4, 8, 2, 349.00, 698.00),

(11, 5, 5, 1, 1999.00, 1999.00),
(12, 5, 1, 1, 799.00, 799.00),
(13, 5, 17, 1, 499.00, 499.00),

(14, 6, 14, 2, 349.00, 698.00),
(15, 6, 11, 3, 249.00, 747.00),
(16, 6, 12, 2, 149.00, 298.00),

(17, 7, 13, 1, 899.00, 899.00),
(18, 7, 9, 1, 2999.00, 2999.00),
(19, 7, 15, 2, 249.00, 498.00),
(20, 7, 16, 1, 349.00, 349.00);

-- One-time recalculation of order totals from items (if needed)

UPDATE orders o
JOIN (
  SELECT order_id, SUM(line_total) AS total
  FROM order_items
  GROUP BY order_id
) t ON o.id = t.order_id
SET o.total_amount = t.total;

-- Example reporting queries

-- Top products by revenue
SELECT
  p.id,
  p.name,
  SUM(oi.quantity) AS total_quantity_sold,
  SUM(oi.line_total) AS total_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_revenue DESC
LIMIT 5;

-- Top customers by total spent
SELECT
  c.id,
  c.first_name,
  c.last_name,
  c.email,
  SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.first_name, c.last_name, c.email
ORDER BY total_spent DESC
LIMIT 5;

-- Low stock products
SELECT
  id,
  name,
  stock
FROM products
WHERE stock <= 10
ORDER BY stock ASC;

-- Monthly revenue (paid or shipped orders)
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(total_amount) AS monthly_revenue
FROM orders
WHERE status IN ('paid', 'shipped')
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
