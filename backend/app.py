# backend/app.py

from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from config import DATABASE_CONFIG

import datetime
from flask.json import JSONEncoder

class CustomJSONEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.timedelta):
            total = int(obj.total_seconds())
            h, rem = divmod(total, 3600)
            m, s = divmod(rem, 60)
            return f"{h:02}:{m:02}:{s:02}"
        return super().default(obj)

app = Flask(__name__)
app.json_encoder = CustomJSONEncoder
CORS(app)

def get_db_connection():
    """
    Establish and return a new connection to the MySQL database using the settings in config.py.
    """
    try:
        conn = mysql.connector.connect(**DATABASE_CONFIG)
        return conn
    except Error as err:
        print("Error connecting to database:", err)
        raise

##############################################
# PROCEDURE ENDPOINTS (POST)
##############################################

@app.route('/api/add_airplane', methods=['POST'])
def add_airplane():
    """
    Calls the 'add_airplane' stored procedure.
    Expects JSON with: tail_num, airline_id, seat_cap, plane_type, speed, maintained, location_id, model.
    """
    data = request.get_json()
    tail_num    = data.get('tail_num')
    airline_id  = data.get('airline_id')
    seat_cap    = data.get('seat_cap')
    plane_type  = data.get('plane_type')
    speed       = data.get('speed')
    maintained  = data.get('maintained')
    location_id = data.get('location_id')
    model       = data.get('model')  # can be None
    neo         = data.get('neo')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Adjust the parameter order below to match your stored procedure
        args = [airline_id,tail_num, seat_cap, speed,location_id,plane_type,maintained,model,neo]
        cursor.callproc('add_airplane', args)
        conn.commit()
        return jsonify({'message': 'Airplane added successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn: 
            conn.close()

@app.route('/api/add_airport', methods=['POST'])
def add_airport():
    """
    Calls the 'add_airport' stored procedure.
    Expects JSON with: state, airport_id, airport_name, country, city, location_id.
    """
    data = request.get_json()
    state        = data.get('state')
    airport_id   = data.get('airport_id')
    airport_name = data.get('airport_name')
    country      = data.get('country')
    city         = data.get('city')
    location_id  = data.get('location_id')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        args = [airport_id, airport_name, city, state, country, location_id]
        cursor.callproc('add_airport', args)
        conn.commit()
        return jsonify({'message': 'Airport added successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn: 
            conn.close()

@app.route('/api/add_person', methods=['POST'])
def add_person():
    """
    Calls the 'add_person' stored procedure.
    Expects JSON with: location_id, miles, person_id, first_name, tax_id, funds, last_name, experience.
    """
    data = request.get_json()
    location_id = data.get('location_id')
    miles       = data.get('miles')
    person_id   = data.get('person_id')
    first_name  = data.get('first_name')
    tax_id      = data.get('tax_id')
    funds       = data.get('funds')
    last_name   = data.get('last_name')
    experience  = data.get('experience')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        args = [person_id, first_name, last_name, location_id, tax_id, experience, miles,funds]
        cursor.callproc('add_person', args)
        conn.commit()
        return jsonify({'message': 'Person added successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn: 
            conn.close()

@app.route('/api/pilot_license', methods=['POST'])
def pilot_license():
    """
    Grants or revokes a pilot license.
    Expects JSON with: action ('grant' or 'revoke'), license, person_id.
    The stored procedure should handle both actions based on input.
    """
    data = request.get_json()
    license_  = data.get('license')
    person_id = data.get('person_id')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        args = [person_id, license_]  # Adjust parameters as per your stored procedure
        cursor.callproc('grant_or_revoke_pilot_license', args)
        conn.commit()
        return jsonify({'message': 'Pilot license action completed successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/offer_flight', methods=['POST'])
def offer_flight():
    """
    Calls the 'offer_flight' stored procedure.
    Expects JSON with: progress, cost, flight_id, route_id, next_time, airline, tail.
    """
    data = request.get_json()
    progress  = data.get('progress')
    cost      = data.get('cost')
    flight_id = data.get('flight_id')
    route_id  = data.get('route_id')
    next_time = data.get('next_time')
    airline   = data.get('airline')
    tail      = data.get('tail')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        args = [progress, cost, flight_id, route_id, next_time, airline, tail]
        cursor.callproc('offer_flight', args)
        conn.commit()
        return jsonify({'message': 'Flight offered successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/flight_landing', methods=['POST'])
def flight_landing():
    """
    Calls the 'flight_landing' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('flight_landing', [flightID])
        conn.commit()
        return jsonify({'message': 'Flight landed successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/flight_takeoff', methods=['POST'])
def flight_takeoff():
    """
    Calls the 'flight_takeoff' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('flight_takeoff', [flightID])
        conn.commit()
        return jsonify({'message': 'Flight took off successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/passengers_board', methods=['POST'])
def passengers_board():
    """
    Calls the 'passengers_board' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('passengers_board', [flightID])
        conn.commit()
        return jsonify({'message': 'Passengers boarded successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/passengers_disembark', methods=['POST'])
def passengers_disembark():
    """
    Calls the 'passengers_disembark' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('passengers_disembark', [flightID])
        conn.commit()
        return jsonify({'message': 'Passengers disembarked successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/assign_pilot', methods=['POST'])
def assign_pilot():
    """
    Calls the 'assign_pilot' stored procedure.
    Expects JSON with: flightID and personID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    personID = data.get('personID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        args = [flightID, personID]
        cursor.callproc('assign_pilot', args)
        conn.commit()
        return jsonify({'message': 'Pilot assigned successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/recycle_crew', methods=['POST'])
def recycle_crew():
    """
    Calls the 'recycle_crew' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('recycle_crew', [flightID])
        conn.commit()
        return jsonify({'message': 'Crew recycled successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/retire_flight', methods=['POST'])
def retire_flight():
    """
    Calls the 'retire_flight' stored procedure.
    Expects JSON with: flightID.
    """
    data = request.get_json()
    flightID = data.get('flightID')
    
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('retire_flight', [flightID])
        conn.commit()
        return jsonify({'message': 'Flight retired successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/simulation_cycle', methods=['POST'])
def simulation_cycle():
    """
    Calls the 'simulation_cycle' stored procedure.
    This endpoint does not need additional parameters.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc('simulation_cycle')
        conn.commit()
        return jsonify({'message': 'Simulation cycle executed successfully.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

##############################################
# VIEW ENDPOINTS (GET)
##############################################

@app.route('/api/flights_in_the_air', methods=['GET'])
def flights_in_the_air():
    """
    Retrieves data from the 'flights_in_the_air' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM flights_in_the_air;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/flights_on_the_ground', methods=['GET'])
def flights_on_the_ground():
    """
    Retrieves data from the 'flights_on_the_ground' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM flights_on_the_ground;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/people_in_the_air', methods=['GET'])
def people_in_the_air():
    """
    Retrieves data from the 'people_in_the_air' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM people_in_the_air;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/people_on_the_ground', methods=['GET'])
def people_on_the_ground():
    """
    Retrieves data from the 'people_on_the_ground' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM people_on_the_ground;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/route_summary', methods=['GET'])
def route_summary():
    """
    Retrieves data from the 'route_summary' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM route_summary;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

@app.route('/api/alternate_airports', methods=['GET'])
def alternate_airports():
    """
    Retrieves data from the 'alternative_airports' view.
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM alternative_airports;")
        result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    finally:
        if conn:
            conn.close()

##############################################
# Application Entry Point
##############################################

if __name__ == '__main__':
    app.run(debug=True, port=5000)
