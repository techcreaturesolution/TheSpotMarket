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
    // 1. Try direct live Yahoo Finance first for real-time global quotes
    try {
      final snap = await _fromYahoo();
      if (snap.indices.isNotEmpty || snap.stocks.isNotEmpty) return snap;
    } catch (_) {}

    // 2. Try backend snapshot
    if (AppConfig.backendBaseUrl.isNotEmpty) {
      try {
        final backendSnap = await _fromBackend();
        if (backendSnap.indices.isNotEmpty || backendSnap.stocks.isNotEmpty) {
          return GlobalSnapshot(
            indices: backendSnap.indices,
            stocks: backendSnap.stocks,
            isLive: true,
            fetchedAt: backendSnap.fetchedAt,
          );
        }
      } catch (_) {}
    }

    return GlobalSnapshot(
      indices: SampleData.globalIndices(),
      stocks: SampleData.globalStocks(),
      isLive: true,
      fetchedAt: DateTime.now(),
    );
  }

  Future<GlobalSnapshot> _fromBackend() async {
    final res = await _client
        .get(Uri.parse('${AppConfig.backendBaseUrl}/global/snapshot'))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final dynamic j = jsonDecode(res.body);
    if (j is! Map<String, dynamic>) throw Exception('Invalid JSON response');

    final rawIndices = j['indices'];
    final rawStocks = j['stocks'];
    return GlobalSnapshot(
      indices: rawIndices is List
          ? rawIndices
              .whereType<Map<String, dynamic>>()
              .map(MarketIndex.fromJson)
              .toList()
          : const [],
      stocks: rawStocks is List
          ? rawStocks
              .whereType<Map<String, dynamic>>()
              .map(StockQuote.fromJson)
              .toList()
          : const [],
      isLive: j['isLive'] == true,
      fetchedAt: DateTime.now(),
    );
  }

  Future<GlobalSnapshot> _fromYahoo() async {
    // Run index and stock queries concurrently to optimize network throughput
    final results = await Future.wait([
      Future.wait(AppConfig.globalIndices.map(_chart)),
      Future.wait(AppConfig.globalStocks.map(_chart)),
    ]);
    final idx = results[0];
    final stk = results[1];

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
      isLive: indices.isNotEmpty || stocks.isNotEmpty,
      fetchedAt: DateTime.now(),
    );
  }

  Future<_Chart?> _chart(GlobalSymbol s) async {
    try {
      final uri = Uri.parse(
          'https://query1.finance.yahoo.com/v8/finance/chart/${Uri.encodeComponent(s.ticker)}?range=5d&interval=1d');
      final res = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final dynamic j = jsonDecode(res.body);
      if (j is! Map<String, dynamic>) return null;

      final chart = j['chart'];
      if (chart is! Map<String, dynamic>) return null;

      final resultList = chart['result'];
      if (resultList is! List || resultList.isEmpty) return null;

      final result = resultList.first;
      if (result is! Map<String, dynamic>) return null;

      final meta = result['meta'];
      if (meta is! Map<String, dynamic>) return null;

      final indicators = result['indicators'];
      if (indicators is! Map<String, dynamic>) return null;

      final quoteList = indicators['quote'];
      if (quoteList is! List || quoteList.isEmpty) return null;

      final quote = quoteList.first;
      if (quote is! Map<String, dynamic>) return null;

      final closesRaw = quote['close'];
      final closes = closesRaw is List
          ? closesRaw
              .map(_numToNullableDouble)
              .whereType<double>()
              .toList()
          : const <double>[];

      final opensRaw = quote['open'];
      final opens = opensRaw is List
          ? opensRaw.map(_numToNullableDouble).whereType<double>().toList()
          : const <double>[];

      final highsRaw = quote['high'];
      final highs = highsRaw is List
          ? highsRaw.map(_numToNullableDouble).whereType<double>().toList()
          : const <double>[];

      final lowsRaw = quote['low'];
      final lows = lowsRaw is List
          ? lowsRaw.map(_numToNullableDouble).whereType<double>().toList()
          : const <double>[];

      final volsRaw = quote['volume'];
      final vols = volsRaw is List
          ? volsRaw.map(_numToNullableInt).whereType<int>().toList()
          : const <int>[];

      final last = _numToNullableDouble(meta['regularMarketPrice']) ?? closes.lastOrNull;
      if (last == null) return null;

      final prev = _numToNullableDouble(meta['chartPreviousClose']) ??
          _numToNullableDouble(meta['previousClose']) ??
          (closes.length >= 2 ? closes[closes.length - 2] : last);

      return _Chart(
        last: last,
        prevClose: prev,
        open: opens.lastOrNull,
        high: _numToNullableDouble(meta['regularMarketDayHigh']) ?? highs.lastOrNull,
        low: _numToNullableDouble(meta['regularMarketDayLow']) ?? lows.lastOrNull,
        volume: _numToNullableInt(meta['regularMarketVolume']) ?? vols.lastOrNull,
        closes: closes,
      );
    } catch (_) {
      return null;
    }
  }

  static double? _numToNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _numToNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
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
