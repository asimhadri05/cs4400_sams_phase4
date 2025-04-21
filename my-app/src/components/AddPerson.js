// src/components/AddPerson.js
import React, { useState } from 'react';
import '../App.css'; // Import the CSS

function AddPerson() {
  const [formData, setFormData] = useState({
    location_id: '',
    miles: '',
    person_id: '',
    first_name: '',
    tax_id: '',
    funds: '',
    last_name: '',
    experience: ''
  });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // helper to turn "" or "null" into null, otherwise parse
  const parseIntOrNull = v => {
    if (!v || v.trim().toLowerCase() === 'null') return null;
    return parseInt(v, 10);
  };
  const parseFloatOrNull = v => {
    if (!v || v.trim().toLowerCase() === 'null') return null;
    return parseFloat(v);
  };


  const handleSubmit = async (e) => {
    e.preventDefault();

    // Adjust endpoint as needed:
    // build a payload that sends real nulls, not the string "null"
    const payload = {
      location_id: formData.location_id,
      person_id:   formData.person_id,
      first_name:  formData.first_name,
      last_name:   formData.last_name  || null,

      // for a pilot these two will be non‐null, for a passenger these will be null
      tax_id:      formData.tax_id.trim() === '' || formData.tax_id.trim() === 'null' ? null : formData.tax_id.trim(),
      experience:  parseIntOrNull(formData.experience),

      // for a passenger these two will be non‐null, for a pilot these will be null
      miles:       parseIntOrNull(formData.miles),
      funds:       parseFloatOrNull(formData.funds),
    };


    try {
      const res = await fetch('/api/add_person', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Person added successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div className="container">
      <h2>Add Person</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Location ID:
          <input type="text" name="location_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Miles:
          <input type="text" name="miles" onChange={handleChange} />
        </label>
        <br />
        <label>
          Person ID:
          <input type="text" name="person_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          First Name:
          <input type="text" name="first_name" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Tax ID:
          <input type="text" name="tax_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Funds:
          <input type="text" name="funds" onChange={handleChange} />
        </label>
        <br />
        <label>
          Last Name:
          <input type="text" name="last_name" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Experience:
          <input type="text" name="experience" onChange={handleChange} required />
        </label>
        <br />
        <button type="submit">Add</button>
        <button type="button" onClick={() => setFormData({})}>Cancel</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default AddPerson;
