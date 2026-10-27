const express = require('express');
const router = express.Router();
const aiController = require('../controllers/ai.controller');
const { aiLimiter } = require('../middleware/rateLimiter');

router.post(['/api/ai/chat', '/ai/chat'], aiLimiter, aiController.chat);

module.exports = router;
