const globalService = require('../services/global.service');

function getGlobalSnapshot(req, res) {
  const snapshot = globalService.getGlobalSnapshot();
  return res.json(snapshot);
}

module.exports = {
  getGlobalSnapshot
};
