const env = require('../config/env');

function buildIpoResponse(result, filterState, lastFetchTime) {
  const data = result.data ? result.data.filter(i => !filterState || i.state === filterState) : [];
  return {
    success: result.data !== null,
    source: result.source,
    isLive: result.isLive,
    stale: result.stale,
    fetchedAt: lastFetchTime ? new Date(lastFetchTime).toISOString() : null,
    cacheTtlSeconds: env.IPO_CACHE_TTL_MS / 1000,
    data
  };
}

module.exports = {
  buildIpoResponse
};
