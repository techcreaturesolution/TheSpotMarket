const env = require('../config/env');
const { smart_api, getAngelSession, resetAngelSession } = require('../config/smartApi.config');
const { mapAngelPayloadToSchema } = require('../utils/marketMapper');

let marketCacheData = null;
let marketCacheTime = 0;
let currentMarketPromise = null;

const tokensToTrack = [
  "2885", "1333", "4963", "1594", "11536", "1660", "11483",
  "5900", "1922", "3045", "1394", "10604", "317", "236",
  "3456", "3499", "10999", "3506", "3351", "2031", "7229", "3787"
];

async function performMarketFetch() {
  try {
    await getAngelSession();

    const payload = {
      mode: "FULL",
      exchangeTokens: {
        "NSE": tokensToTrack
      }
    };

    const res = await smart_api.marketData(payload);

    if (!res.status || !res.data || !res.data.fetched) {
      throw new Error('Failed to fetch market data from Angel One');
    }

    const allStocks = res.data.fetched.map(mapAngelPayloadToSchema);

    let gainers = allStocks.filter(s => s.changePct > 0);
    gainers.sort((a, b) => b.changePct - a.changePct);

    let losers = allStocks.filter(s => s.changePct < 0);
    losers.sort((a, b) => a.changePct - b.changePct);

    console.log(`[MARKET_MOVERS] Angel One fetched=${res.data.fetched.length} gainers=${gainers.length} losers=${losers.length}`);

    return { gainers, losers };
  } catch (err) {
    console.error('[MARKET_MOVERS] Angel One Fetch failed:', err.message);
    if (err.message.includes('Invalid Token') || err.message.includes('Session')) {
      resetAngelSession();
    }
    return null;
  }
}

async function getMarketData() {
  const now = Date.now();
  if (marketCacheData && (now - marketCacheTime < env.MARKET_CACHE_TTL_MS)) {
    console.log('[MARKET_MOVERS] cache=HIT age=' + Math.round((now - marketCacheTime) / 1000) + 's');
    return { data: marketCacheData, isLive: true, stale: false, source: 'IndianAPI' };
  }

  if (!currentMarketPromise) {
    console.log('[MARKET_MOVERS] source=IndianAPI cache=MISS');
    currentMarketPromise = performMarketFetch().then(res => {
      currentMarketPromise = null;
      if (res) {
        marketCacheData = res;
        marketCacheTime = Date.now();
        console.log(`[MARKET_MOVERS] source=IndianAPI gainers=${res.gainers.length} losers=${res.losers.length} isLive=true`);
        return { data: res, isLive: true, stale: false, source: 'IndianAPI' };
      } else {
        if (marketCacheData) {
          console.log('[MARKET_MOVERS] source=IndianAPI status=FAILED using_stale_cache=true');
          return { data: marketCacheData, isLive: false, stale: true, source: 'IndianAPI' };
        } else {
          console.log('[MARKET_MOVERS] source=IndianAPI status=FAILED');
          return { data: null, isLive: false, stale: false, source: 'IndianAPI' };
        }
      }
    });
  } else {
    console.log('[MARKET_MOVERS] cache=IN_FLIGHT_WAIT');
  }

  return await currentMarketPromise;
}

function getMarketCacheTime() {
  return marketCacheTime;
}

function getDefaultIndices() {
  return [
    { name: 'NIFTY 50', exchange: 'NSE', last: 24998.45, change: 134.20, changePct: 0.54, previousClose: 24864.25, sparkline: [24850, 24890, 24920, 24960, 24998.45] },
    { name: 'NIFTY BANK', exchange: 'NSE', last: 51804.70, change: 268.90, changePct: 0.52, previousClose: 51535.80, sparkline: [51500, 51580, 51650, 51720, 51804.7] },
    { name: 'NIFTY IT', exchange: 'NSE', last: 42150.30, change: 512.40, changePct: 1.23, previousClose: 41637.90, sparkline: [41600, 41750, 41900, 42050, 42150.3] },
    { name: 'BSE SENSEX', exchange: 'BSE', last: 81820.12, change: 442.30, changePct: 0.54, previousClose: 81377.82, sparkline: [81350, 81480, 81590, 81710, 81820.12] },
    { name: 'INDIA VIX', exchange: 'NSE', last: 13.08, change: -0.42, changePct: -3.11, previousClose: 13.50, sparkline: [13.6, 13.4, 13.3, 13.15, 13.08] }
  ];
}

module.exports = {
  performMarketFetch,
  getMarketData,
  getMarketCacheTime,
  getDefaultIndices
};
