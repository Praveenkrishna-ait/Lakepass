const { pool } = require('./db');

const createTables = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      role VARCHAR(20) DEFAULT 'customer', -- 'customer' or 'operator'
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS marinas (
      id SERIAL PRIMARY KEY,
      operator_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      name VARCHAR(100) NOT NULL,
      location VARCHAR(255) NOT NULL,
      description TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS slips (
      id SERIAL PRIMARY KEY,
      marina_id INTEGER REFERENCES marinas(id) ON DELETE CASCADE,
      name VARCHAR(50) NOT NULL,
      length INTEGER NOT NULL, -- in feet
      width INTEGER NOT NULL, -- in feet
      price_per_night DECIMAL(10, 2) NOT NULL,
      is_available BOOLEAN DEFAULT TRUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS bookings (
      id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      slip_id INTEGER REFERENCES slips(id) ON DELETE CASCADE,
      start_date DATE NOT NULL,
      end_date DATE NOT NULL,
      total_price DECIMAL(10, 2) NOT NULL,
      status VARCHAR(20) DEFAULT 'confirmed', -- 'confirmed', 'cancelled'
      payment_id VARCHAR(255), -- Razorpay payment ID
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    console.log('Creating tables...');
    await pool.query(queryText);
    console.log('Tables created successfully!');
  } catch (err) {
    console.error('Error creating tables:', err);
  } finally {
    pool.end();
  }
};

createTables();
