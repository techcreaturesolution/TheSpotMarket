function getGlobalSnapshot() {
  const indices = [
    { name: 'S&P 500', exchange: 'USA', last: 5864.67, change: 24.15, changePct: 0.41, previousClose: 5840.52, sparkline: [5810, 5825, 5838, 5845, 5864.67] },
    { name: 'Dow Jones', exchange: 'USA', last: 43077.70, change: 201.36, changePct: 0.47, previousClose: 42876.34, sparkline: [42900, 42950, 43010, 43050, 43077.7] },
    { name: 'NASDAQ', exchange: 'USA', last: 18367.08, change: 60.52, changePct: 0.33, previousClose: 18306.56, sparkline: [18280, 18310, 18330, 18350, 18367.08] },
    { name: 'FTSE 100', exchange: 'UK', last: 8292.66, change: 43.58, changePct: 0.53, previousClose: 8249.08, sparkline: [8230, 8250, 8270, 8285, 8292.66] },
    { name: 'DAX', exchange: 'Germany', last: 19508.29, change: 134.40, changePct: 0.69, previousClose: 19373.89, sparkline: [19400, 19430, 19470, 19495, 19508.29] },
    { name: 'Nikkei 225', exchange: 'Japan', last: 39605.80, change: 345.20, changePct: 0.88, previousClose: 39260.60, sparkline: [39300, 39400, 39480, 39550, 39605.8] },
    { name: 'Hang Seng', exchange: 'Hong Kong', last: 20318.79, change: -145.21, changePct: -0.71, previousClose: 20464.00, sparkline: [20500, 20450, 20400, 20350, 20318.79] },
    { name: 'Gold', exchange: 'Commodity', last: 2662.80, change: 14.20, changePct: 0.54, previousClose: 2648.60, sparkline: [2640, 2648, 2655, 2658, 2662.8] },
    { name: 'Crude Oil (WTI)', exchange: 'Commodity', last: 70.58, change: -1.20, changePct: -1.67, previousClose: 71.78, sparkline: [72.2, 71.8, 71.2, 70.9, 70.58] },
    { name: 'USD / INR', exchange: 'Forex', last: 84.07, change: 0.02, changePct: 0.02, previousClose: 84.05, sparkline: [84.02, 84.03, 84.05, 84.06, 84.07] }
  ];

  const stocks = [
    { symbol: 'NVDA', name: 'NVIDIA', lastPrice: 138.25, change: 4.65, changePct: 3.48, volume: 245000000, sector: 'Semiconductors', currency: '$', sparkline: [128, 131, 133.6, 135.2, 138.25] },
    { symbol: 'AAPL', name: 'Apple', lastPrice: 229.50, change: 2.10, changePct: 0.92, volume: 52000000, sector: 'Technology', currency: '$', sparkline: [225, 226.4, 227.1, 228.3, 229.5] },
    { symbol: 'MSFT', name: 'Microsoft', lastPrice: 418.90, change: 3.40, changePct: 0.82, volume: 21000000, sector: 'Technology', currency: '$', sparkline: [412, 414, 416.2, 417.5, 418.9] },
    { symbol: 'GOOGL', name: 'Alphabet', lastPrice: 172.60, change: 1.20, changePct: 0.70, volume: 26000000, sector: 'Technology', currency: '$', sparkline: [168, 169.5, 171, 171.8, 172.6] },
    { symbol: 'AMZN', name: 'Amazon', lastPrice: 189.30, change: -0.80, changePct: -0.42, volume: 38000000, sector: 'Retail', currency: '$', sparkline: [191, 190.2, 189.8, 189.5, 189.3] },
    { symbol: 'META', name: 'Meta Platforms', lastPrice: 578.40, change: 6.90, changePct: 1.21, volume: 12000000, sector: 'Technology', currency: '$', sparkline: [560, 565, 569, 574, 578.4] },
    { symbol: 'TSLA', name: 'Tesla', lastPrice: 248.70, change: -9.40, changePct: -3.64, volume: 98000000, sector: 'Auto', currency: '$', sparkline: [262, 259, 255, 251, 248.7] },
    { symbol: 'JPM', name: 'JPMorgan Chase', lastPrice: 221.40, change: -2.60, changePct: -1.16, volume: 9000000, sector: 'Banking', currency: '$', sparkline: [226, 225.1, 224.3, 223, 221.4] },
    { symbol: 'NFLX', name: 'Netflix', lastPrice: 762.10, change: 5.20, changePct: 0.69, volume: 3000000, sector: 'Media', currency: '$', sparkline: [748, 752, 755, 758, 762.1] },
    { symbol: 'TSM', name: 'Taiwan Semiconductor', lastPrice: 196.40, change: 3.80, changePct: 1.97, volume: 11000000, sector: 'Semiconductors', currency: '$', sparkline: [188, 190, 192.5, 194, 196.4] }
  ];

  return {
    success: true,
    isLive: true,
    fetchedAt: new Date().toISOString(),
    indices,
    stocks
  };
}

module.exports = {
  getGlobalSnapshot
};
