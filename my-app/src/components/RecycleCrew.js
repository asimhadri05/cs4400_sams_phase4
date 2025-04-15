// src/components/RecycleCrew.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function RecycleCrew() {
  const [flightID, setFlightID] = useState('');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/recycle_crew', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ flightID })
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Crew recycled successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Recycle Crew</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Flight ID:
          <input
            type="text"
            value={flightID}
            onChange={(e) => setFlightID(e.target.value)}
            required
          />
        </label>
        <br />
        <button type="submit">Recycle Crew</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default RecycleCrew;
