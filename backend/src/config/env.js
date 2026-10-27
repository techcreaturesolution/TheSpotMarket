require('dotenv').config();

const env = {
  PORT: process.env.PORT || 3000,
  INDIANAPI_KEY: process.env.INDIANAPI_KEY || '',
  INDIANAPI_BASE_URL: process.env.INDIANAPI_BASE_URL || 'https://stock.indianapi.in',
  IPO_CACHE_TTL_MS: (parseInt(process.env.IPO_CACHE_TTL_SECONDS, 10) || 600) * 1000,
  COOLDOWN_MS: 5 * 60 * 1000,
  MARKET_CACHE_TTL_MS: 60000,
  ANGEL_API_KEY: process.env.ANGEL_API_KEY || '',
  ANGEL_CLIENT_ID: process.env.ANGEL_CLIENT_ID || '',
  ANGEL_PASSWORD: process.env.ANGEL_PASSWORD || '',
  ANGEL_TOTP_SECRET: process.env.ANGEL_TOTP_SECRET || '',
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || process.env.AI_API_KEY || ''
};

module.exports = env;
