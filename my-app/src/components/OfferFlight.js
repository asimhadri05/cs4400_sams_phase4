// src/components/OfferFlight.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function OfferFlight() {
  const [formData, setFormData] = useState({
    progress: '',
    cost: '',
    flight_id: '',
    route_id: '',
    next_time: '',
    airline: '',
    tail: ''
  });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/offer_flight', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if(res.ok) {
        setMessage("Flight offered successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch(error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Offer Flight</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Progress:
          <input type="text" name="progress" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Cost:
          <input type="number" name="cost" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Flight ID:
          <input type="text" name="flight_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Route ID:
          <input type="text" name="route_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Next Time:
          <input type="text" name="next_time" onChange={handleChange} required placeholder="HH:MM:SS"/>
        </label>
        <br />
        <label>
          Airline:
          <input type="text" name="airline" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Tail:
          <input type="text" name="tail" onChange={handleChange} required />
        </label>
        <br />
        <button type="submit">Offer Flight</button>
        <button type="button" onClick={() => setFormData({})}>Cancel</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default OfferFlight;
