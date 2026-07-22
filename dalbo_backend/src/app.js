const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const authRoutes       = require('./routes/auth');
const restaurantRoutes = require('./routes/restaurants');
const orderRoutes      = require('./routes/orders');
const adminRoutes      = require('./routes/admin');

const app = express();

app.use(cors());
app.use(express.json());

// Limit each IP to 100 requests per 15 minutes to prevent abuse
const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use(limiter);

app.use('/api/auth',        authRoutes);
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/orders',      orderRoutes);
app.use('/api/admin',       adminRoutes);

app.get('/health', (_req, res) =>
  res.json({ status: 'ok', app: 'Dalbo API v1' })
);

// Global error handler
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

module.exports = app;
