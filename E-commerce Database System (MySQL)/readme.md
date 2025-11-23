🛒 E-Commerce Database System (MySQL)

A complete end-to-end relational database design for a basic online shopping platform, built using MySQL (v6-compatible).
This project is simple, realistic, and fully hand-written — perfect for learning, interviews, or showcasing on GitHub.

📌 Project Overview

This project demonstrates how a real e-commerce backend works using a clean SQL structure.
It covers customers, products, categories, orders, and order items, along with inventory triggers and reporting queries.

Designed to be easy to understand and modify.

🧱 Database Structure
Main Tables

customers – user details, email, phone, full address

categories – product category list

products – product info (SKU, price, stock)

orders – order header (customer + status + total)

order_items – detailed items inside each order

Included Features

Primary & foreign keys

Indexes on email, SKU, category_id, product_id

Logical naming

MySQL-friendly structure for older versions (no CTE, no window functions)

📦 Sample Data Included

The project comes with realistic, hand-written sample entries:

10 categories

12+ customers from different Indian cities

18 products with proper SKUs & stock

7 real-looking orders

20 order_items linked properly

All INSERTs are manually written — no loops or auto-generation.

⚙️ Automated Stock Management (Triggers)

Three triggers manage inventory automatically:

After INSERT → reduce product stock

After UPDATE → adjust stock based on quantity change

After DELETE → restore stock

This simulates how real inventory systems behave.

💰 Order Total Recalculation

Whenever items are added/updated/removed:

The order’s total_amount is recalculated with a simple UPDATE + GROUP BY.

No complex SQL — fully MySQL-compatible.

🔧 Stored Procedures

Two useful procedures:

Customer Order Summary

Returns all orders for any given customer

Top Customers

Ranks customers based on total spending

These are perfect for API integration or admin dashboards.

📊 Reporting View

A simple view customer_order_totals shows:

Customer name

Number of orders

Total money spent

Good for BI or analytics.

📈 Example Reporting Queries

Top Selling Products

Top Customers by Revenue

Low Stock Items

Monthly Revenue Summary

These queries help you analyze performance and inventory health.

🚀 How to Use

Copy the full SQL script

Run it in MySQL Workbench / phpMyAdmin / CLI

All tables, data, triggers, procedures auto-setup

Run reporting queries to see insights
