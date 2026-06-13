const { pool } = require('./db');

async function migrate() {
  try {
    await pool.query('ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_id VARCHAR(255)');
    console.log('Migration complete: payment_id column added to bookings table.');
  } catch (err) {
    console.error('Migration error:', err.message);
  } finally {
    pool.end();
  }
}

migrate();
