const tokenNameMap = {
  "2885": "RELIANCE",
  "1333": "HDFCBANK",
  "4963": "ICICIBANK",
  "1594": "INFY",
  "11536": "TCS",
  "1660": "LT",
  "11483": "LT",
  "5900": "AXISBANK",
  "1922": "KOTAKBANK",
  "3045": "SBIN",
  "1394": "HINDUNILVR",
  "10604": "BHARTIARTL",
  "317": "BAJFINANCE",
  "236": "ASIANPAINT",
  "3456": "TATAMOTORS",
  "3499": "TATASTEEL",
  "10999": "MARUTI",
  "3506": "TITAN",
  "3351": "SUNPHARMA",
  "2031": "M&M",
  "7229": "TATAINVEST",
  "3787": "WIPRO"
};

function mapAngelPayloadToSchema(tokenData) {
  const ltp = parseFloat(tokenData.ltp) || 0;
  const close = parseFloat(tokenData.close) || ltp;
  const change = ltp - close;
  const changePct = close !== 0 ? (change / close) * 100 : 0;

  const rawToken = (tokenData.symbolToken || tokenData.token || '').toString();
  const mappedSymbol = tokenNameMap[rawToken] || tokenData.tradingsymbol || rawToken || 'NSE Equity';

  return {
    symbol: mappedSymbol,
    name: mappedSymbol,
    lastPrice: ltp,
    changePct: parseFloat(changePct.toFixed(2)),
    change: parseFloat(change.toFixed(2)),
    exchange: 'NSE', // Enforcing clean UI string
    date: new Date().toISOString().split('T')[0],
    time: new Date().toISOString().split('T')[1].substring(0, 8),
    volume: 0,
    high: parseFloat(tokenData.high) || 0,
    low: parseFloat(tokenData.low) || 0,
    open: parseFloat(tokenData.open) || 0,
    close: close
  };
}

module.exports = {
  tokenNameMap,
  mapAngelPayloadToSchema
};
