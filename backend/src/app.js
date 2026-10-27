const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const { generalLimiter } = require('./middleware/rateLimiter');

const app = express();

// Trust Render / Cloud reverse proxy
app.set('trust proxy', 1);

// HTTP Security Headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  if (req.secure || req.headers['x-forwarded-proto'] === 'https') {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  next();
});

// Controlled CORS Policy (Permit mobile app / non-browser requests, restrict web origins)
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(s => s.trim().toLowerCase())
  : [
      'https://thespotmarket-1.onrender.com',
      'https://thespotmarket.com',
      'http://localhost:5173',
      'http://127.0.0.1:5173',
      'http://localhost:5180',
      'http://127.0.0.1:5180',
      'http://localhost:5181',
      'http://127.0.0.1:5181',
      'http://localhost:3000',
      'http://127.0.0.1:3000'
    ];

app.use(cors({
  origin: (origin, callback) => {
    // Mobile apps and CLI tools don't send an Origin header
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin.toLowerCase())) {
      return callback(null, true);
    }
    // Reject untrusted browser origins
    return callback(new Error('Cross-Origin Request Blocked by CORS Policy'));
  },
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-goog-api-key', 'X-Api-Key']
}));

// Request Body Limits
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: true, limit: '100kb' }));

// Global Rate Limiter
app.use(generalLimiter);

// Master Route Registration
app.use('/', routes);

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Central Error Handler
app.use((err, req, res, next) => {
  if (err.message && err.message.includes('CORS Policy')) {
    return res.status(403).json({
      success: false,
      error: 'CORS_FORBIDDEN',
      message: err.message
    });
  }
  console.error('[UNHANDLED_ERROR]', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

module.exports = app;
