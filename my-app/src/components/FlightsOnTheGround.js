// src/components/FlightsOnTheGround.js
import React, { useEffect, useState } from 'react';
import '../App.css'; // Import the CSS

function FlightsOnTheGround() {
  const [flights, setFlights] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/flights_on_the_ground')
      .then(response => response.json())
      .then(data => setFlights(data))
      .catch(err => setError(err.toString()));
  }, []);

  return (
    <div className="container">
      <h2>Flights On The Ground</h2>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {flights.length === 0 ? (
        <p>No data found.</p>
      ) : (
        <table border="1" cellPadding="5">
          <thead>
            <tr>
              <th>Departing From</th>
              <th># Flights</th>
              <th>Flight List</th>
              <th>Earliest Arrival</th>
              <th>Latest Arrival</th>
              <th>Airplane List</th>
            </tr>
          </thead>
          <tbody>
            {flights.map((flight, index) => (
              <tr key={index}>
                <td>{flight.departing_from}</td>
                <td>{flight.num_flights}</td>
                <td>{flight.flight_list}</td>
                <td>{flight.earliest_arrival}</td>
                <td>{flight.latest_arrival}</td>
                <td>{flight.airplane_list}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default FlightsOnTheGround;
