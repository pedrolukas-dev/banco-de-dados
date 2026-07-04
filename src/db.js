const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'petvida',
    port: 3307 // Sua porta do XAMPP
});

module.exports = pool;