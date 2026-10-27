const express = require('express');
const router = express.Router();
const contactController = require('../controllers/contact.controller');
const { contactLimiter } = require('../middleware/rateLimiter');

// POST /contact and POST /api/contact endpoints protected by dedicated rate limiter
router.post(['/api/contact', '/contact'], contactLimiter, contactController.submitContact);

module.exports = router;
