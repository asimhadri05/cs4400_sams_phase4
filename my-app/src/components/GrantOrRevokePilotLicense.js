// src/components/GrantOrRevokePilotLicense.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function GrantOrRevokePilotLicense() {
  const [formData, setFormData] = useState({
    license: '',
    person_id: ''
  });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    let endpoint = '/api/pilot_license';
    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Pilot license action successful.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Grant or Revoke Pilot License</h2>
      <form onSubmit={handleSubmit}>
        <br />
        <label>
          License:
          <input type="text" name="license" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Person ID:
          <input type="text" name="person_id" onChange={handleChange} required />
        </label>
        <br />
        <button type="submit">{'Grant / Revoke'}</button>
        <button type="button" onClick={() => setFormData({ license: '', person_id: '' })}>Cancel</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default GrantOrRevokePilotLicense;
