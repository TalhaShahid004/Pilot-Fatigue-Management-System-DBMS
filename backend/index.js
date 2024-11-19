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

//API TO VERIFY PILOT CREDENTIALS (LOGIN PAGE)
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



// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
