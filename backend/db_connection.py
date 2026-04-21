import mysql.connector
from mysql.connector import Error

def get_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="1234",
            database="ez_system"
        )

        if conn.is_connected():
            print("Successfully connected to MySQL database")
            return conn

    except Error as e:
        print("Error while connecting to MySQL:", e)
        return None
    
    # 👉 ADD THIS TEST PART
if __name__ == "__main__":
    conn = get_connection()

    if conn:
        print("📦 Connection object created successfully")
        conn.close()