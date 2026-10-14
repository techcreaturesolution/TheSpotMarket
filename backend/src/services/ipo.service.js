const axios = require('axios');
const env = require('../config/env');
const { parseIpoItem } = require('../utils/ipoParser');

let lastSuccessfulData = null;
let lastFetchTime = null;
let currentFetchPromise = null;
let cooldownUntil = 0;

async function performIndianApiFetch() {
  console.log('[IPO_RUNTIME] provider=IndianAPI');
  try {
    const res = await axios.get(`${env.INDIANAPI_BASE_URL}/ipo`, {
      headers: { 'X-Api-Key': env.INDIANAPI_KEY },
      timeout: 10000
    });

    const rawData = res.data || {};
    console.log('[LIVE_IPO_API_RESPONSE]');
    console.log(JSON.stringify(res.data, null, 2));

    const combined = [
      ...(rawData.active || []),
      ...(rawData.upcoming || []),
      ...(rawData.pre_apply || []),
      ...(rawData.closed || []),
      ...(rawData.listed || [])
    ];

    console.log('[IPO_RUNTIME] status=200');
    console.log(`[IPO_RUNTIME] records_fetched=${combined.length}`);
    console.log(`[IPO_RUNTIME] upcoming=${rawData.upcoming ? rawData.upcoming.length : 0}`);
    console.log(`[IPO_RUNTIME] active=${rawData.active ? rawData.active.length : 0}`);
    console.log(`[IPO_RUNTIME] listed=${rawData.listed ? rawData.listed.length : 0}`);

    const ipos = [];
    const seenSymbols = new Set();

    combined.forEach(item => {
      const parsed = parseIpoItem(item);
      if (parsed && !seenSymbols.has(parsed.symbol.toLowerCase())) {
        seenSymbols.add(parsed.symbol.toLowerCase());
        ipos.push(parsed);
      }
    });

    let openCount = 0;
    let upcomingCount = 0;

    ipos.forEach(ipo => {
      if (ipo.state === 'OPEN') openCount++;
      if (ipo.state === 'UPCOMING') upcomingCount++;
    });

    console.log(`[IPO_RUNTIME] open_count=${openCount}`);
    console.log(`[IPO_RUNTIME] upcoming_count=${upcomingCount}`);
    console.log('[IPO_RUNTIME] cache=UPDATED');

    lastSuccessfulData = ipos;
    lastFetchTime = Date.now();
    return { data: ipos, isLive: true, stale: false, source: 'IndianAPI' };
  } catch (error) {
    if (error.response && error.response.status === 401) {
      console.log('[IPO_RUNTIME] status=401');
      console.log('[IPO_RUNTIME] error=UNAUTHORIZED');
      cooldownUntil = Date.now() + env.COOLDOWN_MS;
      return { data: lastSuccessfulData, isLive: false, stale: true, source: 'IndianAPI', error: 'UNAUTHORIZED' };
    }
    console.log('[IPO_RUNTIME] status=ERROR');
    console.log(`[IPO_RUNTIME] error=${error.message}`);
    return { data: lastSuccessfulData, isLive: false, stale: true, source: 'IndianAPI', error: error.message };
  } finally {
    currentFetchPromise = null;
  }
}

async function getIpoData() {
  const now = Date.now();
  if (now < cooldownUntil) {
    console.log('[IPO_RUNTIME] cache=HIT_STALE_COOLDOWN');
    return { data: lastSuccessfulData, isLive: false, stale: true, source: 'IndianAPI', error: 'COOLDOWN' };
  }

  if (lastSuccessfulData && lastFetchTime && (now - lastFetchTime < env.IPO_CACHE_TTL_MS)) {
    console.log('[IPO_RUNTIME] cache=HIT');
    return { data: lastSuccessfulData, isLive: true, stale: false, source: 'IndianAPI' };
  }

  if (!currentFetchPromise) {
    console.log('[IPO_RUNTIME] cache=MISS');
    currentFetchPromise = performIndianApiFetch();
  } else {
    console.log('[IPO_RUNTIME] cache=IN_FLIGHT_WAIT');
  }

  return await currentFetchPromise;
}

function triggerCooldownTest() {
  cooldownUntil = Date.now() + env.COOLDOWN_MS;
  lastSuccessfulData = [];
  return { success: true, message: 'Cooldown triggered manually' };
}

function getLastFetchTime() {
  return lastFetchTime;
}

module.exports = {
  getIpoData,
  triggerCooldownTest,
  getLastFetchTime
};
