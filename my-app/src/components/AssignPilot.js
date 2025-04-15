// src/components/AssignPilot.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function AssignPilot() {
  const [formData, setFormData] = useState({ flightID: '', personID: '' });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/assign_pilot', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Pilot assigned successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Assign Pilot</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Flight ID:
          <input
            type="text"
            name="flightID"
            value={formData.flightID}
            onChange={handleChange}
            required
          />
        </label>
        <br />
        <label>
          Person ID:
          <input
            type="text"
            name="personID"
            value={formData.personID}
            onChange={handleChange}
            required
          />
        </label>
        <br />
        <button type="submit">Assign Pilot</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default AssignPilot;
