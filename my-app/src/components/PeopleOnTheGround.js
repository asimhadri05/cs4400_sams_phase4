// src/components/PeopleOnTheGround.js
import React, { useEffect, useState } from 'react';
import '../App.css'; // Import the CSS

function PeopleOnTheGround() {
  const [data, setData] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/people_on_the_ground')
      .then(response => response.json())
      .then(data => setData(data))
      .catch(err => setError(err.toString()));
  }, []);

  return (
    <div className="container">
      <h2>People On The Ground</h2>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      {data.length === 0 ? (
        <p>No data found.</p>
      ) : (
        <table border="1" cellPadding="5">
          <thead>
            <tr>
              <th>Departing From</th>
              <th>Airport Name</th>
              <th>City</th>
              <th>State</th>
              <th>Country</th>
              <th># Pilots</th>
              <th># Passengers</th>
              <th>Joint Pilots/Passengers</th>
              <th>Person List</th>
            </tr>
          </thead>
          <tbody>
            {data.map((entry, index) => (
              <tr key={index}>
                <td>{entry.departing_from}</td>
                <td>{entry.airport_name}</td>
                <td>{entry.city}</td>
                <td>{entry.state}</td>
                <td>{entry.country}</td>
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

export default PeopleOnTheGround;
