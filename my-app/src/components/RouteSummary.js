// src/components/RouteSummary.js
import React, { useEffect, useState } from 'react';
import '../App.css'; // Import the CSS

function RouteSummary() {
  const [routes, setRoutes] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/route_summary')
      .then(response => response.json())
      .then(data => setRoutes(data))
      .catch(err => setError(err.toString()));
  }, []);

  return (
    <div className="container">
      <h2>Route Summary</h2>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {routes.length === 0 ? (
        <p>No data found.</p>
      ) : (
        <table border="1" cellPadding="5">
          <thead>
            <tr>
              <th>Route</th>
              <th># Legs</th>
              <th>Leg Sequence</th>
              <th>Route Length</th>
              <th># Flights</th>
              <th>Flight List</th>
              <th>Airport Sequence</th>
            </tr>
          </thead>
          <tbody>
            {routes.map((route, index) => (
              <tr key={index}>
                <td>{route.route}</td>
                <td>{route.num_legs}</td>
                <td>{route.leg_sequence}</td>
                <td>{route.route_length}</td>
                <td>{route.num_flights}</td>
                <td>{route.flight_list}</td>
                <td>{route.airport_sequence}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default RouteSummary;
