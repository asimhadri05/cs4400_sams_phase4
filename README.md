# Flight Tracker App

A full‐stack web application for tracking and managing flights. It consists of a React frontend, a Flask backend, and a MySQL database (managed via SQL Workbench). Two developers split the work evenly.

---

## 🛠️ Prerequisites

- **Node.js** (v14+)
- **Python 3.8+**  
- **MySQL** server (8.0+)
- **SQL Workbench** (or any MySQL client)

---

## ⚙️ Setup

1. **Clone the repo**  
   ```bash
   git clone https://github.com/asimhadri05/cs4400_sams_phase4.git
   cd flight-tracker
   ```

2. **Database**  
   - Open **SQL Workbench**, connect to your local MySQL server.  
   - In the `db/` folder you’ll find:
     - `cs4400_sams_phase3_database_v0.sql` — creates tables  
     - `cs4400_phase3_stored_procedures_team94_.sql` — user-defined functions, and views that the backend calls   
   - Run them **in order** to set up your schema, functions, and views.

3. **Backend**  
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate      # macOS/Linux
   venv\Scripts\activate       # Windows
   pip install -r requirements.txt
   ```

4. **Frontend**  
   ```bash
   cd ../frontend
   npm install
   ```

---

## ▶️ Running the App

1. **Start the database**  
   Make sure MySQL is running and your schema/functions/views have been applied.

2. **Launch the backend**  
   ```bash
   cd backend
   flask run
   # or: python app.py
   ```
   By default it listens on `http://localhost:5000`.

3. **Launch the frontend**  
   ```bash
   cd ../frontend
   npm start
   ```
   Opens at `http://localhost:3000`.

---

## 🔧 Technologies & Architecture

- **Frontend**:  
  - React (Create React App)  
  - **Fetch API** for all HTTP calls
  - Functional components + React Hooks  

- **Backend**:  
  - Flask (Flask-RESTful)  
  - No authentication layer  
  - Exposes JSON endpoints consumed by the frontend  

- **Database**:  
  - MySQL, managed via SQL Workbench  
  - SQL scripts define tables, **functions** (stored routines), and **views**  
  - Backend calls these functions/views for all data operations  

---

## 🙋 Team Contributions

We split work evenly and collaborated closely on API design, data modeling, and integration testing.

- Sathwik Nemani 
  - Designed and implemented React UI components  
  - Wrote all front-end fetch calls and state management  
  - Styled layouts, handled routing  

- Aditya Simhadri 
  - Designed database schema in SQL Workbench  
  - Authored `functions.sql` and `views.sql`  
  - Built Flask endpoints that call those functions/views  
  - Wrote data-validation logic in the backend  

Both members reviewed each other’s code, wrote unit tests for key endpoints, and co-authored this README.
