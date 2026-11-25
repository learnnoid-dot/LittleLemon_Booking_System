# Little Lemon Booking System — Database & Analytics Project

## Project Overview
This repository contains the relational database design, MySQL stored procedures, Python client integration, and Tableau reporting assets for **Little Lemon**:
- **`little_lemon_schema_and_procedures.sql`**: Creates `little_lemon_db` (`Customers`, `DiningTables`, `Staff`, `MenuItems`, `Bookings`, `Orders`), inserts sample test records, and defines all five required stored procedures:
  1. `GetMaxQuantity()`
  2. `ManageBooking(p_BookingDate, p_TableNumber)`
  3. `AddBooking(p_CustomerID, p_TableID, p_StaffID, p_BookingDate, p_NumberOfGuests)`
  4. `UpdateBooking(p_BookingID, p_BookingDate, p_NumberOfGuests)`
  5. `CancelBooking(p_BookingID)`
- **`little_lemon_booking_client.py`**: Python client connecting to MySQL via `mysql-connector-python`, executing stored procedures, and handling event reactions when bookings are added, updated, or cancelled.
- **`little_lemon_er_diagram.png`**: Entity Relationship diagram illustrating table relationships and keys.
- **`little_lemon_tableau_reporting_data.csv`**: Sample booking and order dataset ready to connect to Tableau Desktop for sales and booking reports.
