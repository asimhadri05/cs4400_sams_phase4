// frontend/src/App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import AddAirplane from './components/AddAirplane';

function App() {
  return (
    <Router>
      <div>
        <nav>
          <ul>
            <li><Link to="/add-airplane">Add Airplane</Link></li>
            {/* Add more links for other procedures/views */}
          </ul>
        </nav>
        <Routes>
          <Route path="/add-airplane" element={<AddAirplane />} />
          {/* Define additional routes as needed */}
        </Routes>
      </div>
    </Router>
  );
}

export default App;

