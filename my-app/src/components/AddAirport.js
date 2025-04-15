// src/components/AddAirport.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function AddAirport() {
  const [formData, setFormData] = useState({
    state: '',
    airport_id: '',
    airport_name: '',
    international: false,
    country: '',
    city: '',
    location_id: ''
  });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
    setFormData({ ...formData, [e.target.name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Adjust endpoint and payload accordingly:
    try {
      const res = await fetch('/api/add_airport', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Airport added successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Add Airport</h2>
      <form onSubmit={handleSubmit}>
        <label>
          State:
          <input type="text" name="state" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Airport ID:
          <input type="text" name="airport_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Airport Name:
          <input type="text" name="airport_name" onChange={handleChange} required />
        </label>
        <label>
          Country:
          <input type="text" name="country" onChange={handleChange} required />
        </label>
        <br />
        <label>
          City:
          <input type="text" name="city" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Location ID:
          <input type="text" name="location_id" onChange={handleChange} required />
        </label>
        <br />
        <button type="submit">Add</button>
        <button type="button" onClick={() => setFormData({})}>Cancel</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default AddAirport;
