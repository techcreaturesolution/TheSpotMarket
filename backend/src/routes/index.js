const express = require('express');
const router = express.Router();

const ipoRoutes = require('./ipo.routes');
const marketRoutes = require('./market.routes');
const globalRoutes = require('./global.routes');
const aiRoutes = require('./ai.routes');
const contactRoutes = require('./contact.routes');

// Health Check
router.get(['/api/health', '/health'], (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString()
  });
});

// Mount route modules at root level to maintain 100% backward compatibility
router.use('/', ipoRoutes);
router.use('/', marketRoutes);
router.use('/', globalRoutes);
router.use('/', aiRoutes);
router.use('/', contactRoutes);

module.exports = router;
