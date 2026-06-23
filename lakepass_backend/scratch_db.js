const { Pool } = require('pg');
require('dotenv').config();

const dbUrl = new URL(process.env.DATABASE_URL);
const pool = new Pool({
  user: dbUrl.username,
  password: dbUrl.password,
  host: dbUrl.hostname,
  port: dbUrl.port || 5432,
  database: dbUrl.pathname.replace('/', ''),
  ssl: {
    rejectUnauthorized: false,
  },
});

pool.query('SELECT * FROM marinas')
  .then(res => {
    console.log(res.rows);
    process.exit(0);
  })
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
