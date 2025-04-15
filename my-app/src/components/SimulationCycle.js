// src/components/SimulationCycle.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function SimulationCycle() {
  const [message, setMessage] = useState('');

  const handleSimulation = async () => {
    try {
      const res = await fetch('/api/simulation_cycle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Simulation cycle triggered successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Simulation Cycle</h2>
      <button onClick={handleSimulation}>Trigger Simulation Cycle</button>
      {message && <p>{message}</p>}
    </div>
  );
}

export default SimulationCycle;
