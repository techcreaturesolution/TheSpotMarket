const env = require('../config/env');
const axios = require('axios');
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

const trackedIndicesConfig = [
  { symbol: '^NSEI', name: 'NIFTY 50', exchange: 'NSE' },
  { symbol: '^NSEBANK', name: 'NIFTY BANK', exchange: 'NSE' },
  { symbol: '^CNXIT', name: 'NIFTY IT', exchange: 'NSE' },
  { symbol: '^BSESN', name: 'BSE SENSEX', exchange: 'BSE' },
  { symbol: '^INDIAVIX', name: 'INDIA VIX', exchange: 'NSE' }
];

let indicesCacheData = null;
let indicesCacheTime = 0;
const INDICES_CACHE_TTL_MS = 15000; // 15 seconds cache

async function fetchLiveIndicesFromYahoo() {
  const now = Date.now();
  if (indicesCacheData && (now - indicesCacheTime < INDICES_CACHE_TTL_MS)) {
    return indicesCacheData;
  }

  try {
    const results = await Promise.all(
      trackedIndicesConfig.map(async (cfg) => {
        try {
          const url = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(cfg.symbol)}?range=1d&interval=15m`;
          const res = await axios.get(url, {
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
              'Accept': 'application/json'
            },
            timeout: 6000
          });

          const chart = res.data?.chart?.result?.[0];
          const meta = chart?.meta;
          if (!meta) return null;

          const last = parseFloat(meta.regularMarketPrice) || 0;
          const prev = parseFloat(meta.chartPreviousClose || meta.previousClose) || last;
          const change = parseFloat((last - prev).toFixed(2));
          const changePct = prev !== 0 ? parseFloat(((change / prev) * 100).toFixed(2)) : 0;

          const rawCloses = chart?.indicators?.quote?.[0]?.close || [];
          const sparkline = rawCloses
            .filter(p => typeof p === 'number' && !isNaN(p))
            .map(p => parseFloat(p.toFixed(2)));

          return {
            name: cfg.name,
            exchange: cfg.exchange,
            last,
            change,
            changePct,
            open: parseFloat(meta.regularMarketDayLow) || last,
            high: parseFloat(meta.regularMarketDayHigh) || last,
            low: parseFloat(meta.regularMarketDayLow) || last,
            previousClose: prev,
            sparkline: sparkline.length > 0 ? sparkline : [prev, last]
          };
        } catch (err) {
          console.error(`[MARKET_INDICES] Yahoo fetch error for ${cfg.symbol}:`, err.message);
          return null;
        }
      })
    );

    const successful = results.filter(Boolean);
    if (successful.length > 0) {
      indicesCacheData = successful;
      indicesCacheTime = Date.now();
      console.log(`[MARKET_INDICES] Successfully fetched ${successful.length} live indices from Yahoo Finance`);
      return successful;
    }
  } catch (globalErr) {
    console.error('[MARKET_INDICES] Failed to fetch indices from Yahoo Finance:', globalErr.message);
  }

  if (indicesCacheData) {
    return indicesCacheData;
  }

  return getDefaultIndices();
}

function getDefaultIndices() {
  return [
    { name: 'NIFTY 50', exchange: 'NSE', last: 22975.85, change: 39.10, changePct: 0.17, previousClose: 22936.75, sparkline: [22930, 22945, 22960, 22970, 22975.85] },
    { name: 'NIFTY BANK', exchange: 'NSE', last: 49650.20, change: 110.50, changePct: 0.22, previousClose: 49539.70, sparkline: [49520, 49580, 49610, 49650.2] },
    { name: 'NIFTY IT', exchange: 'NSE', last: 38450.30, change: 212.40, changePct: 0.56, previousClose: 38237.90, sparkline: [38200, 38300, 38380, 38450.3] },
    { name: 'BSE SENSEX', exchange: 'BSE', last: 75410.12, change: 130.30, changePct: 0.17, previousClose: 75279.82, sparkline: [75260, 75320, 75380, 75410.12] },
    { name: 'INDIA VIX', exchange: 'NSE', last: 13.08, change: -0.42, changePct: -3.11, previousClose: 13.50, sparkline: [13.6, 13.4, 13.3, 13.15, 13.08] }
  ];
}

module.exports = {
  performMarketFetch,
  getMarketData,
  getMarketCacheTime,
  getDefaultIndices,
  fetchLiveIndicesFromYahoo
};
