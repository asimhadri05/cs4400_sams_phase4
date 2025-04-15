import React, { useState } from 'react';

function AddAirplane() {
  const [formData, setFormData] = useState({
    airline_id: '',
    tail_num: '',
    seat_cap: '',
    plane_type: '',
    speed: '',
    maintained: '',
    location_id: '',
    model: ''
  });
  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/add_airplane', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if (res.ok) {
        setMessage("Airplane added successfully.");
      } else {
        setMessage("Error: " + data.error);
      }
    } catch (error) {
      setMessage("Request failed: " + error.toString());
    }
  };

  return (
    <div>
      <h2>Add Airplane</h2>
      <form onSubmit={handleSubmit}>
        <label>
          Airline ID:
          <input type="text" name="airline_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Tail Number:
          <input type="text" name="tail_num" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Seat Capacity:
          <input type="number" name="seat_cap" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Plane Type:
          <input type="text" name="plane_type" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Speed:
          <input type="number" name="speed" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Maintained:
          <input type="text" name="maintained" onChange={handleChange} />
        </label>
        <br />
        <label>
          Location ID:
          <input type="text" name="location_id" onChange={handleChange} required />
        </label>
        <br />
        <label>
          Model:
          <input type="text" name="model" onChange={handleChange} />
        </label>
        <br />
        <button type="submit">Add Airplane</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
}

export default AddAirplane;
