// src/components/Navigation.js
import React from 'react';
import { Link } from 'react-router-dom';
import '../App.css'; // Import the CSS

function Navigation() {
  return (
    <nav style={{ padding: '1rem', background: '#f0f0f0' }}>
      <Link style={{ margin: '0 1rem' }} to="/">Home</Link>
      <Link style={{ margin: '0 1rem' }} to="/add-airplane">Add Airplane</Link>
      <Link style={{ margin: '0 1rem' }} to="/add-airport">Add Airport</Link>
      <Link style={{ margin: '0 1rem' }} to="/add-person">Add Person</Link>
      <Link style={{ margin: '0 1rem' }} to="/pilot-license">Pilot License</Link>
      <Link style={{ margin: '0 1rem' }} to="/offer-flight">Offer Flight</Link>
      <Link style={{ margin: '0 1rem' }} to="/flight-landing">Flight Landing</Link>
      <Link style={{ margin: '0 1rem' }} to="/flight-takeoff">Flight Takeoff</Link>
      <Link style={{ margin: '0 1rem' }} to="/passengers-board">Board</Link>
      <Link style={{ margin: '0 1rem' }} to="/passengers-disembark">Disembark</Link>
      <Link style={{ margin: '0 1rem' }} to="/assign-pilot">Assign Pilot</Link>
      <Link style={{ margin: '0 1rem' }} to="/recycle-crew">Recycle Crew</Link>
      <Link style={{ margin: '0 1rem' }} to="/retire-flight">Retire Flight</Link>
      <Link style={{ margin: '0 1rem' }} to="/simulation-cycle">Sim Cycle</Link>
      <Link style={{ margin: '0 1rem' }} to="/flights-in-the-air">Flights in the Air</Link>
      <Link style={{ margin: '0 1rem' }} to="/flights-on-the-ground">Flights on the Ground</Link>
      <Link style={{ margin: '0 1rem' }} to="/people-in-the-air">People in the Air</Link>
      <Link style={{ margin: '0 1rem' }} to="/people-on-the-ground">People on the Ground</Link>
      <Link style={{ margin: '0 1rem' }} to="/route-summary">Route Summary</Link>
      <Link style={{ margin: '0 1rem' }} to="/alternate-airports">Alternate Airports</Link>
    </nav>
  );
}

export default Navigation;
