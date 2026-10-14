const { SmartAPI } = require('smartapi-javascript');
const { TOTP } = require('totp-generator');
const env = require('./env');

const smart_api = new SmartAPI({
  api_key: env.ANGEL_API_KEY
});

let smartApiSession = null;

async function getAngelSession() {
  if (smartApiSession) return smartApiSession;

  try {
    const { otp } = await TOTP.generate(env.ANGEL_TOTP_SECRET);
    const session = await smart_api.generateSession(
      env.ANGEL_CLIENT_ID,
      env.ANGEL_PASSWORD,
      otp
    );

    if (session.status) {
      smartApiSession = session.data;
      return smartApiSession;
    } else {
      throw new Error(session.message || 'Angel One login failed');
    }
  } catch (error) {
    console.error('[ANGEL_ONE] Authentication Error:', error.message);
    smartApiSession = null;
    throw error;
  }
}

function resetAngelSession() {
  smartApiSession = null;
}

module.exports = {
  smart_api,
  getAngelSession,
  resetAngelSession
};
