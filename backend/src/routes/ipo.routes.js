const express = require('express');
const router = express.Router();
const ipoController = require('../controllers/ipo.controller');

router.get('/ipo/open', ipoController.getOpenIpos);
router.get('/ipo/upcoming', ipoController.getUpcomingIpos);
router.get('/ipo/closed', ipoController.getClosedIpos);
router.get('/ipo/listed', ipoController.getListedIpos);
router.get(['/ipos', '/ipo'], ipoController.getAllIpos);

module.exports = router;
