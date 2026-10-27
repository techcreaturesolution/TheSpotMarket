const express = require('express');
const router = express.Router();
const marketController = require('../controllers/market.controller');

router.get('/market/snapshot', marketController.getMarketSnapshot);

module.exports = router;
