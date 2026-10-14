const express = require('express');
const router = express.Router();
const globalController = require('../controllers/global.controller');

router.get('/global/snapshot', globalController.getGlobalSnapshot);

module.exports = router;
