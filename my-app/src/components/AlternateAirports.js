// src/components/AlternateAirports.js
import React, { useEffect, useState } from 'react';
import '../App.css'; // Import the CSS

function AlternateAirports() {
  const [airports, setAirports] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/alternate_airports')
      .then(response => response.json())
      .then(data => setAirports(data))
      .catch(err => setError(err.toString()));
  }, []);

  return (
    <div className="container">
      <h2>Alternate Airports</h2>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {airports.length === 0 ? (
        <p>No data found.</p>
      ) : (
        <table border="1" cellPadding="5">
          <thead>
            <tr>
              <th>City</th>
              <th>State</th>
              <th>Country</th>
              <th># Airports</th>
              <th>Airport Code List</th>
              <th>Airport Names List</th>
            </tr>
          </thead>
          <tbody>
            {airports.map((airport, index) => (
              <tr key={index}>
                <td>{airport.city}</td>
                <td>{airport.state}</td>
                <td>{airport.country}</td>
                <td>{airport.num_airports}</td>
                <td>{airport.airport_code_list}</td>
                <td>{airport.airport_names_list}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default AlternateAirports;
