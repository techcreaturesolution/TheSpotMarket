const ipoService = require('../services/ipo.service');
const { buildIpoResponse } = require('../utils/responseBuilder');

async function getOpenIpos(req, res) {
  const result = await ipoService.getIpoData();
  const resp = buildIpoResponse(result, 'OPEN', ipoService.getLastFetchTime());
  if (!result.data && result.error === 'UNAUTHORIZED') {
    return res.status(503).json(resp);
  }
  return res.json(resp);
}

async function getUpcomingIpos(req, res) {
  const result = await ipoService.getIpoData();
  const resp = buildIpoResponse(result, 'UPCOMING', ipoService.getLastFetchTime());
  if (!result.data && result.error === 'UNAUTHORIZED') {
    return res.status(503).json(resp);
  }
  return res.json(resp);
}

async function getClosedIpos(req, res) {
  const result = await ipoService.getIpoData();
  const resp = buildIpoResponse(result, 'CLOSED', ipoService.getLastFetchTime());
  if (!result.data && result.error === 'UNAUTHORIZED') {
    return res.status(503).json(resp);
  }
  return res.json(resp);
}

async function getListedIpos(req, res) {
  const result = await ipoService.getIpoData();
  const resp = buildIpoResponse(result, 'LISTED', ipoService.getLastFetchTime());
  if (!result.data && result.error === 'UNAUTHORIZED') {
    return res.status(503).json(resp);
  }
  return res.json(resp);
}

async function getAllIpos(req, res) {
  const result = await ipoService.getIpoData();
  const resp = buildIpoResponse(result, null, ipoService.getLastFetchTime());
  if (!result.data && result.error === 'UNAUTHORIZED') {
    return res.status(503).json(resp);
  }
  return res.json(resp);
}

module.exports = {
  getOpenIpos,
  getUpcomingIpos,
  getClosedIpos,
  getListedIpos,
  getAllIpos
};
