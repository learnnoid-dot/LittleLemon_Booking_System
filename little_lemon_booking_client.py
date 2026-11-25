import mysql.connector
from mysql.connector import Error


def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="your_password_here",
        database="little_lemon_db"
    )


def call_get_max_quantity(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.callproc("GetMaxQuantity")
    results = []
    for result in cursor.stored_results():
        results.extend(result.fetchall())
    cursor.close()
    return results


def call_manage_booking(conn, booking_date: str, table_number: int):
    cursor = conn.cursor(dictionary=True)
    cursor.callproc("ManageBooking", [booking_date, table_number])
    results = []
    for result in cursor.stored_results():
        results.extend(result.fetchall())
    cursor.close()
    return results


def call_add_booking(conn, customer_id: int, table_id: int, staff_id: int, booking_date: str, guests: int):
    cursor = conn.cursor(dictionary=True)
    cursor.callproc("AddBooking", [customer_id, table_id, staff_id, booking_date, guests])
    conn.commit()
    results = []
    for result in cursor.stored_results():
        results.extend(result.fetchall())
    cursor.close()
    return results


def call_update_booking(conn, booking_id: int, booking_date: str, guests: int):
    cursor = conn.cursor(dictionary=True)
    cursor.callproc("UpdateBooking", [booking_id, booking_date, guests])
    conn.commit()
    results = []
    for result in cursor.stored_results():
        results.extend(result.fetchall())
    cursor.close()
    return results


def call_cancel_booking(conn, booking_id: int):
    cursor = conn.cursor(dictionary=True)
    cursor.callproc("CancelBooking", [booking_id])
    conn.commit()
    results = []
    for result in cursor.stored_results():
        results.extend(result.fetchall())
    cursor.close()
    return results


def react_to_booking_change(event_type: str, booking_id: int, details: str):
    """Event handler that reacts to booking additions, updates, or cancellations."""
    print(f"[EVENT REACTION] Action={event_type} | BookingID={booking_id} | Details={details}")


if __name__ == "__main__":
    try:
        connection = get_connection()
        if connection.is_connected():
            print("Connected to Little Lemon MySQL database.")

            max_qty = call_get_max_quantity(connection)
            print("Max Quantity:", max_qty)

            availability = call_manage_booking(connection, "2026-11-28 19:00:00", 1)
            print("Availability:", availability)

            added = call_add_booking(connection, 1, 2, 2, "2026-11-28 19:00:00", 3)
            print("Added Booking:", added)
            if added:
                react_to_booking_change("ADDED", added[0]["NewBookingID"], "Table 2 reserved for 3 guests")

            updated = call_update_booking(connection, 1, "2026-11-26 19:30:00", 3)
            print("Updated Booking:", updated)
            react_to_booking_change("UPDATED", 1, "Guest count / time modified")

            cancelled = call_cancel_booking(connection, 4)
            print("Cancelled Booking:", cancelled)
            react_to_booking_change("CANCELLED", 4, "Booking marked as Cancelled")

            connection.close()
    except Error as err:
        print(f"Database error: {err}")
