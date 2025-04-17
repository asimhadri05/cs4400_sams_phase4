// src/components/PeopleInTheAir.js
import React, { useEffect, useState } from 'react';
import '../App.css'; // Import the CSS

function PeopleInTheAir() {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/people_in_the_air')
      .then(response => response.json())
      .then(data => setData(data))
      .catch(err => setError(err.toString()));
  }, []);

  return (
    <div className="container">
      <h2>People In The Air</h2>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {data.length === 0 ? (
        <p>No data found.</p>
      ) : (
        <table border="1" cellPadding="5">
          <thead>
            <tr>
              <th>Departing From</th>
              <th>Arriving At</th>
              <th># Airplanes</th>
              <th>Airplane List</th>
              <th>Flight List</th>
              <th>Earliest Arrival</th>
              <th>Latest Arrival</th>
              <th># Pilots</th>
              <th># Passengers</th>
              <th>Joint Pilots/Passengers</th>
              <th>Persons List</th>
            </tr>
          </thead>
          <tbody>
            {data.map((entry, index) => (
              <tr key={index}>
                <td>{entry.departing_from}</td>
                <td>{entry.arriving_at}</td>
                <td>{entry.num_airplanes}</td>
                <td>{entry.airplane_list}</td>
                <td>{entry.flight_list}</td>
                <td>{entry.earliest_arrival}</td>
                <td>{entry.latest_arrival}</td>
                <td>{entry.num_pilots}</td>
                <td>{entry.num_passengers}</td>
                <td>{entry.joint_pilots_passengers}</td>
                <td>{entry.person_list}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default PeopleInTheAir;
