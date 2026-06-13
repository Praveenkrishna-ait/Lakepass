const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const auth = require('../middleware/auth');

// Get all marinas (Public)
router.get('/', async (req, res) => {
  try {
    const marinas = await pool.query('SELECT * FROM marinas ORDER BY created_at DESC');
    res.json(marinas.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Get single marina (Public)
router.get('/:id', async (req, res) => {
  try {
    const marina = await pool.query('SELECT * FROM marinas WHERE id = $1', [req.params.id]);
    if (marina.rows.length === 0) {
      return res.status(404).json({ msg: 'Marina not found' });
    }
    res.json(marina.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Create a marina (Operator only)
router.post('/', auth, async (req, res) => {
  if (req.user.role !== 'operator') {
    return res.status(403).json({ msg: 'Access denied: Operators only' });
  }

  const { name, location, description } = req.body;
  try {
    const newMarina = await pool.query(
      'INSERT INTO marinas (operator_id, name, location, description) VALUES ($1, $2, $3, $4) RETURNING *',
      [req.user.id, name, location, description]
    );
    res.status(201).json(newMarina.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
