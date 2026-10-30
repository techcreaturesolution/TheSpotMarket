const marketService = require('../services/market.service');

async function getMarketSnapshot(req, res) {
  const [result, indices] = await Promise.all([
    marketService.getMarketData(),
    marketService.fetchLiveIndicesFromYahoo()
  ]);
  const cacheTime = marketService.getMarketCacheTime();

  return res.json({
    success: !!result.data || (indices && indices.length > 0),
    source: result.source || 'YahooFinance',
    isLive: result.isLive || (indices && indices.length > 0),
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

