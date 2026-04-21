from db_connection import get_connection

conn = get_connection()

if conn:
    cursor = conn.cursor()
    cursor.execute("SELECT DATABASE();")
    result = cursor.fetchone()

    print("Current Database:", result)

    cursor.close()
    conn.close()

    #com