const express = require('express');
const router = express.Router();
const { pool } = require('../db');
const auth = require('../middleware/auth');
const Razorpay = require('razorpay');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Create a booking (Customer only)
router.post('/', auth, async (req, res) => {
  const { slip_id, start_date, end_date } = req.body;
  
  try {
    // Check if the slip is available for the given dates
    const conflictingBookings = await pool.query(
      `SELECT * FROM bookings 
       WHERE slip_id = $1 
       AND status = 'confirmed'
       AND ($2 <= end_date AND $3 >= start_date)`,
      [slip_id, start_date, end_date]
    );

    if (conflictingBookings.rows.length > 0) {
      return res.status(400).json({ msg: 'Slip is already booked for these dates' });
    }

    // Calculate total price
    const slip = await pool.query('SELECT price_per_night FROM slips WHERE id = $1', [slip_id]);
    if (slip.rows.length === 0) {
      return res.status(404).json({ msg: 'Slip not found' });
    }
    
    const startDateObj = new Date(start_date);
    const endDateObj = new Date(end_date);
    const diffTime = Math.abs(endDateObj - startDateObj);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    // Minimum 1 night
    const nights = diffDays === 0 ? 1 : diffDays;
    const totalPrice = nights * slip.rows[0].price_per_night;

    const newBooking = await pool.query(
      'INSERT INTO bookings (user_id, slip_id, start_date, end_date, total_price) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.user.id, slip_id, start_date, end_date, totalPrice]
    );

    res.status(201).json(newBooking.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Get user's bookings (Customer)
router.get('/my-bookings', auth, async (req, res) => {
  try {
    const bookings = await pool.query(`
      SELECT b.*, s.name as slip_name, m.name as marina_name 
      FROM bookings b
      JOIN slips s ON b.slip_id = s.id
      JOIN marinas m ON s.marina_id = m.id
      WHERE b.user_id = $1
      ORDER BY b.start_date DESC
    `, [req.user.id]);
    res.json(bookings.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Get all bookings for a marina (Operator)
router.get('/marina/:marinaId', auth, async (req, res) => {
  if (req.user.role !== 'operator') {
    return res.status(403).json({ msg: 'Access denied' });
  }

  try {
    const marina = await pool.query('SELECT * FROM marinas WHERE id = $1 AND operator_id = $2', [req.params.marinaId, req.user.id]);
    if (marina.rows.length === 0) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    const bookings = await pool.query(`
      SELECT b.*, s.name as slip_name, u.name as customer_name, u.email as customer_email
      FROM bookings b
      JOIN slips s ON b.slip_id = s.id
      JOIN users u ON b.user_id = u.id
      WHERE s.marina_id = $1
      ORDER BY b.start_date DESC
    `, [req.params.marinaId]);
    res.json(bookings.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Cancel a booking (Customer or Operator)
router.put('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await pool.query('SELECT * FROM bookings WHERE id = $1', [req.params.id]);
    if (booking.rows.length === 0) {
      return res.status(404).json({ msg: 'Booking not found' });
    }
    
    // Check if user owns the booking OR is the operator of the marina
    // (Simple check for MVP: just verify user owns the booking)
    const bookingData = booking.rows[0];
    if (bookingData.user_id !== req.user.id && req.user.role !== 'operator') {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    // Process Refund if a payment ID exists
    if (bookingData.payment_id) {
      try {
        const amountInPaise = Math.round(parseFloat(bookingData.total_price) * 100);
        await razorpay.payments.refund(bookingData.payment_id, {
          amount: amountInPaise,
          speed: "normal"
        });
        console.log(`Refund processed for payment ${bookingData.payment_id}`);
      } catch (refundErr) {
        console.error('Razorpay Refund Error:', refundErr);
        return res.status(500).json({ msg: 'Failed to process refund. Booking not cancelled.' });
      }
    }

    await pool.query("UPDATE bookings SET status = 'cancelled' WHERE id = $1", [req.params.id]);
    res.json({ msg: 'Booking cancelled and refund initiated' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
