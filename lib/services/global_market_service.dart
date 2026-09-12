import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';
import 'sample_data.dart';

class GlobalSnapshot {
  const GlobalSnapshot({
    required this.indices,
    required this.stocks,
    required this.isLive,
    required this.fetchedAt,
  });

  final List<MarketIndex> indices;
  final List<StockQuote> stocks;
  final bool isLive;
  final DateTime fetchedAt;
}

/// International indices, commodities, forex and large-cap stocks.
///
/// Order of preference:
/// 1. Your own backend (`BACKEND_URL/global/snapshot`).
/// 2. Yahoo Finance public chart endpoint (no key, may rate-limit).
/// 3. Bundled sample data.
class GlobalMarketService {
  GlobalMarketService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
    'Accept': 'application/json',
  };

  Future<GlobalSnapshot> fetchSnapshot() async {
    if (AppConfig.backendBaseUrl.isNotEmpty) {
      try {
        return await _fromBackend();
      } catch (_) {}
    }
    try {
      final snap = await _fromYahoo();
      if (snap.indices.isNotEmpty) return snap;
    } catch (_) {}
    return GlobalSnapshot(
      indices: SampleData.globalIndices(),
      stocks: SampleData.globalStocks(),
      isLive: false,
      fetchedAt: DateTime.now(),
    );
  }

  Future<GlobalSnapshot> _fromBackend() async {
    final res = await _client
        .get(Uri.parse('${AppConfig.backendBaseUrl}/global/snapshot'))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return GlobalSnapshot(
      indices: (j['indices'] as List)
          .cast<Map<String, dynamic>>()
          .map(MarketIndex.fromJson)
          .toList(),
      stocks: (j['stocks'] as List)
          .cast<Map<String, dynamic>>()
          .map(StockQuote.fromJson)
          .toList(),
      isLive: true,
      fetchedAt: DateTime.now(),
    );
  }

  Future<GlobalSnapshot> _fromYahoo() async {
    final idx = await Future.wait(AppConfig.globalIndices.map(_chart));
    final stk = await Future.wait(AppConfig.globalStocks.map(_chart));
    final indices = <MarketIndex>[];
    for (var i = 0; i < idx.length; i++) {
      final c = idx[i];
      if (c == null) continue;
      final sym = AppConfig.globalIndices[i];
      indices.add(MarketIndex(
        name: sym.name,
        exchange: sym.region,
        last: c.last,
        change: c.last - c.prevClose,
        changePct: c.prevClose == 0 ? 0 : (c.last - c.prevClose) / c.prevClose * 100,
        open: c.open,
        high: c.high,
        low: c.low,
        previousClose: c.prevClose,
        sparkline: c.closes,
      ));
    }
    final stocks = <StockQuote>[];
    for (var i = 0; i < stk.length; i++) {
      final c = stk[i];
      if (c == null) continue;
      final sym = AppConfig.globalStocks[i];
      stocks.add(StockQuote(
        symbol: sym.ticker,
        name: sym.name,
        lastPrice: c.last,
        change: c.last - c.prevClose,
        changePct: c.prevClose == 0 ? 0 : (c.last - c.prevClose) / c.prevClose * 100,
        volume: c.volume,
        sector: sym.region,
        currency: sym.currency,
        sparkline: c.closes,
      ));
    }
    return GlobalSnapshot(
      indices: indices,
      stocks: stocks,
      isLive: true,
      fetchedAt: DateTime.now(),
    );
  }

  Future<_Chart?> _chart(GlobalSymbol s) async {
    try {
      final uri = Uri.https('query1.finance.yahoo.com',
          '/v8/finance/chart/${s.ticker}', {'range': '5d', 'interval': '1d'});
      final res = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final result = ((j['chart'] as Map<String, dynamic>)['result'] as List?)?.firstOrNull
          as Map<String, dynamic>?;
      if (result == null) return null;
      final meta = result['meta'] as Map<String, dynamic>;
      final quote = (((result['indicators'] as Map<String, dynamic>)['quote'] as List).first
          as Map<String, dynamic>);
      final closes = (quote['close'] as List?)
              ?.whereType<num>()
              .map((e) => e.toDouble())
              .toList() ??
          const <double>[];
      final opens = (quote['open'] as List?)?.whereType<num>().toList();
      final highs = (quote['high'] as List?)?.whereType<num>().toList();
      final lows = (quote['low'] as List?)?.whereType<num>().toList();
      final vols = (quote['volume'] as List?)?.whereType<num>().toList();
      final last = (meta['regularMarketPrice'] as num?)?.toDouble() ?? closes.lastOrNull;
      if (last == null) return null;
      final prev = (meta['chartPreviousClose'] as num?)?.toDouble() ??
          (meta['previousClose'] as num?)?.toDouble() ??
          (closes.length >= 2 ? closes[closes.length - 2] : last);
      return _Chart(
        last: last,
        prevClose: prev,
        open: opens?.lastOrNull?.toDouble(),
        high: (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? highs?.lastOrNull?.toDouble(),
        low: (meta['regularMarketDayLow'] as num?)?.toDouble() ?? lows?.lastOrNull?.toDouble(),
        volume: (meta['regularMarketVolume'] as num?)?.toInt() ?? vols?.lastOrNull?.toInt(),
        closes: closes,
      );
    } catch (_) {
      return null;
    }
  }
}

class _Chart {
  const _Chart({
    required this.last,
    required this.prevClose,
    required this.closes,
    this.open,
    this.high,
    this.low,
    this.volume,
  });
  final double last;
  final double prevClose;
  final double? open;
  final double? high;
  final double? low;
  final int? volume;
  final List<double> closes;
}
