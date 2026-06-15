const express = require('express');
const router = express.Router();
const Razorpay = require('razorpay');
const crypto = require('crypto');
const { pool } = require('../db');
const auth = require('../middleware/auth');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Step 1: Create a Razorpay Order (called before opening checkout)
router.post('/create-order', auth, async (req, res) => {
  const { slip_id, start_date, end_date } = req.body;

  try {
    // Validate slip exists
    const slip = await pool.query('SELECT * FROM slips WHERE id = $1', [slip_id]);
    if (slip.rows.length === 0) {
      return res.status(404).json({ msg: 'Slip not found' });
    }

    // Check availability (prevent double-booking)
    const conflicting = await pool.query(
      `SELECT * FROM bookings 
       WHERE slip_id = $1 
       AND status = 'confirmed'
       AND ($2 <= end_date AND $3 >= start_date)`,
      [slip_id, start_date, end_date]
    );

    if (conflicting.rows.length > 0) {
      return res.status(400).json({ msg: 'Slip is already booked for these dates' });
    }

    // Calculate total price
    const startDateObj = new Date(start_date);
    const endDateObj = new Date(end_date);
    const diffTime = Math.abs(endDateObj - startDateObj);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    const nights = diffDays === 0 ? 1 : diffDays;
    const totalPrice = nights * parseFloat(slip.rows[0].price_per_night);

    // Amount is in paise (INR smallest unit). 1 INR = 100 paise.
    const amountInPaise = Math.round(totalPrice * 100);

    // Create Razorpay order
    const order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `lakepass_${Date.now()}`,
      notes: {
        slip_id: slip_id.toString(),
        user_id: req.user.id.toString(),
        start_date,
        end_date,
      },
    });

    res.json({
      order_id: order.id,
      amount: amountInPaise,
      currency: order.currency,
      key_id: process.env.RAZORPAY_KEY_ID,
      slip_name: slip.rows[0].name,
      total_price: totalPrice,
    });
  } catch (err) {
    console.error('Create Order Error:', err);
    let errorMessage = 'Failed to create payment order';
    if (err && err.error && err.error.description) {
      errorMessage = err.error.description;
    } else if (err && err.message) {
      errorMessage = err.message;
    }
    res.status(500).json({ msg: errorMessage });
  }
});

// Step 2: Verify payment & create booking (called after Razorpay checkout success)
router.post('/verify', auth, async (req, res) => {
  const {
    razorpay_order_id,
    razorpay_payment_id,
    razorpay_signature,
    slip_id,
    start_date,
    end_date,
  } = req.body;

  try {
    // Verify signature to confirm payment is authentic
    const secret = process.env.RAZORPAY_KEY_SECRET.trim();
    const generatedSignature = crypto
      .createHmac('sha256', secret)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({ msg: 'Payment verification failed. Invalid signature.' });
    }

    // Payment is verified — now create the booking
    const slip = await pool.query('SELECT price_per_night FROM slips WHERE id = $1', [slip_id]);
    if (slip.rows.length === 0) {
      return res.status(404).json({ msg: 'Slip not found' });
    }

    const startDateObj = new Date(start_date);
    const endDateObj = new Date(end_date);
    const diffTime = Math.abs(endDateObj - startDateObj);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    const nights = diffDays === 0 ? 1 : diffDays;
    const totalPrice = nights * parseFloat(slip.rows[0].price_per_night);

    const newBooking = await pool.query(
      `INSERT INTO bookings (user_id, slip_id, start_date, end_date, total_price, status) 
       VALUES ($1, $2, $3, $4, $5, 'confirmed') RETURNING *`,
      [req.user.id, slip_id, start_date, end_date, totalPrice]
    );

    // Store payment reference in the booking (we'll add a column for this)
    await pool.query(
      `UPDATE bookings SET payment_id = $1 WHERE id = $2`,
      [razorpay_payment_id, newBooking.rows[0].id]
    );

    res.status(201).json({
      msg: 'Payment verified and booking confirmed!',
      booking: newBooking.rows[0],
      payment_id: razorpay_payment_id,
    });
  } catch (err) {
    console.error('Verify Payment Error:', err.message);
    res.status(500).json({ msg: 'Payment verification failed' });
  }
});

module.exports = router;
