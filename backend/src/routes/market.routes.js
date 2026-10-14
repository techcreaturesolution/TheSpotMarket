const express = require('express');
const router = express.Router();
const marketController = require('../controllers/market.controller');

router.get('/market/snapshot', marketController.getMarketSnapshot);
router.get('/api/test-market', marketController.testMarketFetch);

module.exports = router;
