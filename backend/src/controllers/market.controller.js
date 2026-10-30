const marketService = require('../services/market.service');

async function getMarketSnapshot(req, res) {
  const result = await marketService.getMarketData();
  const cacheTime = marketService.getMarketCacheTime();
  const angelIndices = result.data ? (result.data.indices || []) : [];
  const indices = await marketService.getLiveIndices(angelIndices);

  const hasAngelLive = angelIndices && angelIndices.length > 0;
  const sourceName = hasAngelLive ? 'AngelOneSmartAPI' : (result.source || 'YahooFinance');

  return res.json({
    success: !!result.data || (indices && indices.length > 0),
    source: sourceName,
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


