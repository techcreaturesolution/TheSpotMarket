const express = require('express');
const router = express.Router();
const ipoController = require('../controllers/ipo.controller');

router.post('/__test/trigger401', ipoController.trigger401Test);

module.exports = router;
