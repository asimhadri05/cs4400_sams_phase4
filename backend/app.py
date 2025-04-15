# backend/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import errorcode
from config import DATABASE_CONFIG

app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Resource Sharing

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DATABASE_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print("Error: ", err)
        return None

@app.route('/api/add_airplane', methods=['POST'])
def add_airplane():
    # Assume the request.json contains the necessary parameters
    data = request.json
    # Sample required fields (adjust as per your stored procedure's needs)
    airline_id = data.get('airline_id')
    tail_num = data.get('tail_num')
    seat_cap = data.get('seat_cap')
    plane_type = data.get('plane_type')
    speed = data.get('speed')
    maintained = data.get('maintained')
    location_id = data.get('location_id')
    model = data.get('model')  # can be NULL
    
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        # Call the stored procedure "add_airplane()"
        # Adjust parameter ordering as required by your procedure
        result = cursor.callproc('add_airplane', [tail_num, airline_id, seat_cap, plane_type, speed, maintained, location_id, model])
        conn.commit()
        return jsonify({"message": "Airplane added successfully"}), 200
    except mysql.connector.Error as err:
        print("SQL Error:", err)
        return jsonify({"error": str(err)}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/flights_in_the_air', methods=['GET'])
def flights_in_the_air():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        # Query the view flights_in_the_air()
        cursor.execute("SELECT * FROM flights_in_the_air;")
        flights = cursor.fetchall()
        return jsonify(flights), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 400
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
