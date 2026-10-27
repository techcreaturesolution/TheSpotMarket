const marketService = require('../services/market.service');

async function getMarketSnapshot(req, res) {
  const result = await marketService.getMarketData();
  const cacheTime = marketService.getMarketCacheTime();
  const indices = marketService.getDefaultIndices();

  return res.json({
    success: !!result.data,
    source: result.source,
    isLive: result.isLive,
    stale: result.stale,
    fetchedAt: cacheTime ? new Date(cacheTime).toISOString() : new Date().toISOString(),
    gainers: result.data ? result.data.gainers : [],
    losers: result.data ? result.data.losers : [],
    indices
  });
}

module.exports = {
  getMarketSnapshot
};
