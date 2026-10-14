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

async function testMarketFetch(req, res) {
  console.log('[TEST ROUTE] Manual Angel One fetch triggered...');
  const result = await marketService.performMarketFetch();
  if (result) {
    return res.json({
      success: true,
      source: 'Angel One SmartAPI',
      message: 'Data fetched and mapped successfully!',
      data: result
    });
  } else {
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch data from Angel One. Check your Node.js terminal for authentication or token errors.'
    });
  }
}

module.exports = {
  getMarketSnapshot,
  testMarketFetch
};
