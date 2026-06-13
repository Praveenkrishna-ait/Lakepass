const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const auth = require('../middleware/auth');

// Get analytics for a specific marina (Operator only)
router.get('/:marinaId', auth, async (req, res) => {
  if (req.user.role !== 'operator') {
    return res.status(403).json({ msg: 'Access denied' });
  }

  try {
    // Verify ownership
    const marina = await pool.query('SELECT * FROM marinas WHERE id = $1 AND operator_id = $2', [req.params.marinaId, req.user.id]);
    if (marina.rows.length === 0) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    // Total Revenue
    const revenueResult = await pool.query(`
      SELECT SUM(b.total_price) as total_revenue
      FROM bookings b
      JOIN slips s ON b.slip_id = s.id
      WHERE s.marina_id = $1 AND b.status = 'confirmed'
    `, [req.params.marinaId]);

    // Total Bookings
    const bookingsCountResult = await pool.query(`
      SELECT COUNT(*) as total_bookings
      FROM bookings b
      JOIN slips s ON b.slip_id = s.id
      WHERE s.marina_id = $1 AND b.status = 'confirmed'
    `, [req.params.marinaId]);

    // Popular Slips (Top 5)
    const popularSlipsResult = await pool.query(`
      SELECT s.name, COUNT(b.id) as booking_count
      FROM slips s
      LEFT JOIN bookings b ON s.id = b.slip_id AND b.status = 'confirmed'
      WHERE s.marina_id = $1
      GROUP BY s.id
      ORDER BY booking_count DESC
      LIMIT 5
    `, [req.params.marinaId]);

    res.json({
      total_revenue: revenueResult.rows[0].total_revenue || 0,
      total_bookings: parseInt(bookingsCountResult.rows[0].total_bookings, 10),
      popular_slips: popularSlipsResult.rows
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
