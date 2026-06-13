require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/marinas', require('./routes/marinas'));
app.use('/api/slips', require('./routes/slips'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/payments', require('./routes/payments'));

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'LakePass API is running' });
});

// Start locally only (Vercel handles listen automatically)
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
}

// Export for Vercel serverless
module.exports = app;
