const express = require('express');
const mysql = require('mysql2');
const bodyParser = require("body-parser");
const app = express();
const port = 3000;
const cors = require("cors");

app.use(cors({
    credentials: true,
}))

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "*");
    next();
});
app.use(express.json());
app.use(bodyParser.urlencoded());

// MySQL connection
const connection = mysql.createConnection({
    host: '127.0.0.1', // Replace with your host
    user: 'root',      // Replace with your username
    password: 'bruhMySQL',      // Replace with your password
    database: 'pfms_db' // Replace with your database name
});

// Test database connection
connection.connect(err => {
    if (err) {
        console.error('Database connection failed:', err.stack);
        return;
    }
    console.log('Connected to the database.');
});

// API route to fetch data
app.get('/data', (req, res) => {
    connection.query('SELECT * FROM pilot', (err, results) => {
        if (err) {
            res.status(500).send('Error fetching data');
            return;
        }
        res.json(results);
    });
});


// POST route to verify pilot credentials
// app.post('/login_verification', (req, res) => {
//     console.log('Received login request:', req);
//     // Extract the username and password from the request body
//     const username = "sali";
//     const password = "password123";
//     console.log(`SELECT * FROM pilot WHERE username = ${username} AND password = ${password};`);
//     // Query to check if a pilot with the given username and password exists
//     connection.query(
//         `SELECT * FROM pilot WHERE username = ? AND password = ?`,
//         {username, password},
//         (err, results) => { 
//             console.log('Query Results:', results);
//             if (err) {
//                 res.status(500).send('Error querying the database ' + err);
//                 return;
//             }

//             // If the query returns any results, credentials are valid
//             if (results.length > 0) {
//                 res.json({ success: true }); // Credentials are correct
//             } else {
//                 res.json({ success: false }); // Invalid credentials
//             }
//         }
//     );
// });



//API TO VERIFY PILOT CREDENTIALS (LOGIN PAGE)
app.post('/login_verification', (req, res) => {
    const { username, password } = req.body;
    // const username = 'sali';
    // const password = 'password123';

    // Correct query with placeholders
    const query = 'SELECT * FROM pilot WHERE username = ? AND password = ?';

    connection.query(query, [username, password], (err, results) => {
        if (err) {
            console.error('Error querying the database:', err);
            res.status(500).send('Error querying the database');
            return;
        }

        // If results are returned, the credentials are valid
        if (results.length > 0) {
            res.json({ success: true });
        } else {
            res.json({ success: false });
        }
    });
});

// API TO GET Upcoming PILOT FLIGHT (PILOT DASHBOARD)
// Function to fetch flight details for a given username
app.post('/getUpcomingFlightDetails', (req, res) => {
    const { username } = req.body;
  
    if (!username) {
      res.status(400).send('Username is required');
      return;
    }
  
    const query = `
        SELECT concat(first_name, ' ', last_name) as full_name, f2.flight_id, route_code, TIMESTAMPDIFF(MINUTE, f2.start_time, f2.end_time) AS flight_time, 
TIME(start_time) as starting_time, DATE_FORMAT(start_time, '%W, %D %M, %Y') AS flight_date
FROM pilot p join flight_assignment f1 using (pilot_id) join flight as f2 using (flight_id) join flight_route f3 using (route_id)
WHERE p.username = ?
ORDER BY flight_date ASC;
    `;
  
    // Execute the query
    connection.query(query, [username], (err, results) => {
      if (err) {
        console.error('Error querying the database:', err);
        res.status(500).send('Error querying the database');
        return;
      }
  
      // Send the results as JSON
      res.json(results);
    });
  });

// API TO GET NEXT PILOT FLIGHTS (PILOT DASHBOARD)
// Function to fetch flight details for a given username
// app.post('/getNextFlightDetails', (req, res) => {
//     const { username } = req.body;
  
//     if (!username) {
//       res.status(400).send('Username is required');
//       return;
//     }
  
//     const query = `
//         SELECT concat(first_name, ' ', last_name) as full_name, f2.flight_id, route_code, TIMESTAMPDIFF(MINUTE, f2.start_time, f2.end_time) AS flight_time, 
//         TIME(start_time) as starting_time, DATE(start_time) as flight_date
//         FROM pilot p join flight_assignment f1 using (pilot_id) join flight as f2 using (flight_id) join flight_route f3 using (route_id)
//         WHERE p.username = ? AND f2.start_time = (
// 	        SELECT min(f.start_time) FROM flight f join flight_assignment fa using (flight_id) where fa.pilot_id = p.pilot_id);
//     `;
  
//     // Execute the query
//     connection.query(query, [username], (err, results) => {
//       if (err) {
//         console.error('Error querying the database:', err);
//         res.status(500).send('Error querying the database');
//         return;
//       }
  
//       // Send the results as JSON
//       res.json(results);
//     });
//   });


// Route to handle pilot registration (signup)
app.post('/registerPilot', (req, res) => {
  const {
    first_name,
    last_name,
    username,
    password,
    airline_code,
    experience,
    date_of_birth,
    email,
    contact_number,
  } = req.body;

  // SQL query to insert new pilot data
  const query = `
    INSERT INTO Pilot (
      first_name, last_name, username, password, airline_code, 
      experience, date_of_birth, email, contact_number
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  const values = [
    first_name, last_name, username, password, airline_code, 
    experience, date_of_birth, email, contact_number
  ];

// Execute the query using connection
connection.query(query, values, (err, result) => {
  if (err) {
    console.error('Error inserting pilot:', err);
    return res.status(500).json({ message: 'Error inserting pilot', error: err });
  }

    // Return success message with inserted pilot ID
    res.status(200).json({ message: 'Pilot registered successfully', pilot_id: result.insertId });
  });
});


// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
