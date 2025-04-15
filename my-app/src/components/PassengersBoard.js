// src/components/PassengersBoard.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function PassengersBoard() {
  const [flightID, setFlightID] = useState('');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/passengers_board', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ flightID })
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Passengers boarded successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Passengers Board</h2>
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
        <button type="submit">Board Passengers</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default PassengersBoard;
