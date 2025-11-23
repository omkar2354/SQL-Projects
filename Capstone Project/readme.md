🚖 Cab Booking System – SQL Database Project

A fully designed relational database for a Cab Booking Application built using MySQL.
This project includes complete schema creation, data insertion, and analytical SQL queries to understand system behavior and performance.

📌 Project Overview

This SQL project models the core structure of a cab booking platform.
It manages customers, drivers, cabs, bookings, trip details, and customer feedback.

Realistic data is included for testing business logic and analytics.

🧱 Database Structure
1. Customers

Stores customer information like name, email, phone, and registration date.

2. Drivers

Contains driver details, license info, joining date, and rating.

3. Cabs

Each cab is linked with a driver, storing vehicle type, number, and capacity.

4. Bookings

Captures complete booking info:

pickup & dropoff

driver assignment

timestamps

trip status (Completed / Cancelled / Ongoing)

cancellation reasons

5. TripDetails

Includes start/end times, distance, fare, and waiting time for each completed booking.

6. Feedback

Customer rating, comments, and feedback date linked to each trip.

📦 Sample Data Included

The project contains complete and realistic datasets:

30 customers

30 drivers

30 cabs

150+ bookings

50+ trip detail entries

50 feedback entries

Data includes actual Mumbai locations, driver ratings, real travel patterns, and mixed ride statuses.

📊 SQL Analytics Included

This project contains a rich set of SQL queries to analyze the system.

Customer Analysis

Customers with the most completed bookings

Customers with high cancellation rates

Busiest days of the week

Driver Performance

Drivers with low average ratings

Longest trips completed

Drivers with high cancellation percentage

Revenue & Business Metrics

Revenue generated month-wise

Most traveled routes

Relationship between driver ratings and earnings

Operational Efficiency

Average waiting time by pickup location

Common cancellation reasons

Revenue from short/medium/long trips

Comparative Analysis

Revenue comparison between Sedan/SUV/Hatchback

Customer churn prediction

Weekend vs weekday demand patterns

🚀 How to Run

Copy and paste the SQL script into MySQL Workbench (or any MySQL client)

Execute the full script

The schema and sample data will be created

Run any analytical query to explore insights
