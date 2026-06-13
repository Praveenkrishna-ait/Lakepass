const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const auth = require('../middleware/auth');

// Get all slips for a specific marina (Public)
router.get('/marina/:marinaId', async (req, res) => {
  try {
    const slips = await pool.query('SELECT * FROM slips WHERE marina_id = $1 ORDER BY created_at DESC', [req.params.marinaId]);
    res.json(slips.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Create a slip (Operator only)
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'operator') {
    return res.status(403).json({ msg: 'Access denied: Operators only' });
  }

  const { marina_id, name, length, width, price_per_night } = req.body;
  
  try {
    // Verify operator owns the marina
    const marina = await pool.query('SELECT * FROM marinas WHERE id = $1 AND operator_id = $2', [marina_id, req.user.id]);
    if (marina.rows.length === 0) {
      return res.status(401).json({ msg: 'Not authorized to add slips to this marina' });
    }

    const newSlip = await pool.query(
      'INSERT INTO slips (marina_id, name, length, width, price_per_night) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [marina_id, name, length, width, price_per_night]
    );
    res.status(201).json(newSlip.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
