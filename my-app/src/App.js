// src/App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navigation from './components/Navigation';
import AddAirplane from './components/AddAirplane';
import AddAirport from './components/AddAirport.js';
import AddPerson from './components/AddPerson';
import GrantOrRevokePilotLicense from './components/GrantOrRevokePilotLicense';
import OfferFlight from './components/OfferFlight';
import FlightLanding from './components/FlightLanding';
import FlightTakeoff from './components/FlightTakeoff';
import PassengersBoard from './components/PassengersBoard';
import PassengersDisembark from './components/PassengersDisembark';
import AssignPilot from './components/AssignPilot';
import RecycleCrew from './components/RecycleCrew';
import RetireFlight from './components/RetireFlight';
import SimulationCycle from './components/SimulationCycle';
import FlightsInTheAir from './components/FlightsInTheAir';
import FlightsOnTheGround from './components/FlightsOnTheGround';
import PeopleInTheAir from './components/PeopleInTheAir';
import PeopleOnTheGround from './components/PeopleOnTheGround';
import RouteSummary from './components/RouteSummary';
import AlternateAirports from './components/AlternateAirports';

function App() {
  return (
    <Router>
      <div>
        <Navigation />
        <Routes>
          <Route path="/add-airplane" element={<AddAirplane />} />
          <Route path="/add-airport" element={<AddAirport />} />
          <Route path="/add-person" element={<AddPerson />} />
          <Route path="/pilot-license" element={<GrantOrRevokePilotLicense />} />
          <Route path="/offer-flight" element={<OfferFlight />} />
          <Route path="/flight-landing" element={<FlightLanding />} />
          <Route path="/flight-takeoff" element={<FlightTakeoff />} />
          <Route path="/passengers-board" element={<PassengersBoard />} />
          <Route path="/passengers-disembark" element={<PassengersDisembark />} />
          <Route path="/assign-pilot" element={<AssignPilot />} />
          <Route path="/recycle-crew" element={<RecycleCrew />} />
          <Route path="/retire-flight" element={<RetireFlight />} />
          <Route path="/simulation-cycle" element={<SimulationCycle />} />
          <Route path="/flights-in-the-air" element={<FlightsInTheAir />} />
          <Route path="/flights-on-the-ground" element={<FlightsOnTheGround />} />
          <Route path="/people-in-the-air" element={<PeopleInTheAir />} />
          <Route path="/people-on-the-ground" element={<PeopleOnTheGround />} />
          <Route path="/route-summary" element={<RouteSummary />} />
          <Route path="/alternate-airports" element={<AlternateAirports />} />
          <Route path="/" element={<h2>Welcome to SAMS Dashboard</h2>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
