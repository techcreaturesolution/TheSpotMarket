import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';
import 'sample_data.dart';

class MarketSnapshot {
  const MarketSnapshot({
    required this.indices,
    required this.gainers,
    required this.losers,
    required this.isLive,
    required this.fetchedAt,
    this.source = MarketDataSource.unknown,
  });

  final List<MarketIndex> indices;
  final List<StockQuote> gainers;
  final List<StockQuote> losers;
  final bool isLive;
  final DateTime fetchedAt;
  final MarketDataSource source;
}

/// Fetches NSE / BSE market data.
///
/// Order of preference:
/// 1. Your own backend (`BACKEND_URL/market/snapshot`) – most reliable.
/// 2. NSE public JSON endpoints (needs a cookie handshake, may be blocked).
/// 3. Bundled sample data so the UI still renders.
class MarketService {
  MarketService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _nseCookie;
  bool _nseBlocked = false;

  static const _nseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9',
    'Referer': 'https://www.nseindia.com/',
  };

  static const _trackedIndicesList = [
    'NIFTY 50',
    'NIFTY BANK',
    'NIFTY IT',
    'NIFTY MIDCAP 100',
    'NIFTY NEXT 50',
    'INDIA VIX',
  ];
  static final _trackedIndicesSet = Set<String>.from(_trackedIndicesList);

  Future<MarketSnapshot> fetchSnapshot() async {
    MarketSnapshot snap;
    try {
      debugPrint('[MARKET_RUNTIME] provider=BACKEND endpoint=${AppConfig.backendBaseUrl}');
      final backendFuture = _fromBackend();
      final yahooFuture = _fromYahoo().catchError((e) {
        debugPrint('[MARKET_RUNTIME] provider=YAHOO for indices failed: $e');
        return MarketSnapshot(indices: [], gainers: [], losers: [], isLive: false, fetchedAt: DateTime.now());
      });

      snap = await backendFuture;
      debugPrint('[MARKET_RUNTIME] BACKEND_SUCCESS');
      if (snap.indices.isEmpty) {
        final ySnap = await yahooFuture;
        snap = MarketSnapshot(
          indices: ySnap.indices,
          gainers: snap.gainers,
          losers: snap.losers,
          isLive: snap.isLive,
          fetchedAt: snap.fetchedAt,
          source: snap.source,
        );
      }
      _logSnapshot(snap);
      return snap;
      } catch (e) {
        String errType = 'BACKEND_HTTP_ERROR';
        final errStr = e.toString();
        if (errStr.contains('TimeoutException')) {
          errType = 'BACKEND_TIMEOUT';
        } else if (errStr.contains('FormatException')) {
          errType = 'BACKEND_PARSE_ERROR';
        } else if (errStr.contains('SocketException')) {
          errType = 'BACKEND_NETWORK_ERROR';
        }
        debugPrint('[MARKET_RUNTIME] $errType fallback_reason=$e');
      }

    if (!_nseBlocked) {
      try {
        debugPrint('[MARKET_RUNTIME] provider=NSE');
        snap = await _fromNse();
        _logSnapshot(snap);
        return snap;
      } catch (e) {
        final err = e.toString();
        debugPrint('[MARKET_RUNTIME] provider=NSE fallback_reason=$err');
        if (err.contains('403') || err.contains('handshake failed') || err.contains('SocketException') || err.contains('Exception: nse')) {
          _nseBlocked = true;
          debugPrint('[MARKET_RUNTIME] NSE permanently blocked for this session due to connection/WAF error.');
        }
      }
    }
    
    try {
      debugPrint('[MARKET_RUNTIME] provider=YAHOO');
      final ySnap = await _fromYahoo();
      if (ySnap.indices.isNotEmpty) {
        _logSnapshot(ySnap);
        return ySnap;
      }
    } catch (e) {
      debugPrint('[MARKET_RUNTIME] provider=YAHOO fallback_reason=$e');
    }

    debugPrint('[MARKET_RUNTIME] SAMPLE_FALLBACK');
    debugPrint('[MARKET_RUNTIME] NO_LIVE_DATA');
    snap = MarketSnapshot(
      indices: SampleData.indices(),
      gainers: SampleData.gainers(),
      losers: SampleData.losers(),
      isLive: false,
      source: MarketDataSource.sampleFallback,
      fetchedAt: DateTime.now(),
    );
    _logSnapshot(snap);
    return snap;
  }

  void _logSnapshot(MarketSnapshot snap) {
    if (kDebugMode) {
      debugPrint(
          '[MARKET_DATA] source=${snap.source.label} status=${snap.isLive ? "LIVE" : "DEMO"} gainers=${snap.gainers.length} losers=${snap.losers.length} fetchedAt=${snap.fetchedAt}');
    }
  }

  Future<MarketSnapshot> _fromYahoo() async {
    final symbols = [
      ('^NSEI', 'NIFTY 50', 'NSE'),
      ('^BSESN', 'SENSEX', 'BSE'),
      ('^NSEBANK', 'NIFTY BANK', 'NSE'),
    ];

    final indices = <MarketIndex>[];
    for (final (ticker, name, exch) in symbols) {
      try {
        final uri = Uri.https('query1.finance.yahoo.com',
            '/v8/finance/chart/$ticker', {'range': '1d', 'interval': '1m'});
        final res = await _client.get(uri, headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final dynamic j = jsonDecode(res.body);
          final result = j?['chart']?['result']?[0];
          final meta = result?['meta'];
          if (meta != null) {
            final double last = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0;
            final double prev = (meta['chartPreviousClose'] as num? ?? meta['previousClose'] as num?)?.toDouble() ?? last;
            final change = last - prev;
            final changePct = prev == 0 ? 0.0 : (change / prev) * 100;
            if (last > 0) {
              indices.add(MarketIndex(
                name: name,
                exchange: exch,
                last: last,
                change: change,
                changePct: changePct,
                open: (meta['regularMarketDayLow'] as num?)?.toDouble() ?? last,
                high: (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? last,
                low: (meta['regularMarketDayLow'] as num?)?.toDouble() ?? last,
                previousClose: prev,
              ));
            }
          }
        }
      } catch (_) {}
    }

    if (indices.isEmpty) throw Exception('Yahoo indices empty');

    return MarketSnapshot(
      indices: indices,
      gainers: SampleData.gainers(),
      losers: SampleData.losers(),
      isLive: false,
      source: MarketDataSource.yahoo,
      fetchedAt: DateTime.now(),
    );
  }

  Future<MarketSnapshot> _fromBackend() async {
    final candidateUrls = [
      '${AppConfig.backendBaseUrl}/market/snapshot',
      if (AppConfig.backendBaseUrl.contains('127.0.0.1') || AppConfig.backendBaseUrl.contains('localhost')) ...[
        'http://192.168.29.254:3000/market/snapshot',
        'http://10.0.2.2:3000/market/snapshot',
      ]
    ];

    Object? lastError;
    for (final uriStr in candidateUrls) {
      final uri = Uri.parse(uriStr);
      try {
        debugPrint('[MARKET_RUNTIME] Fetching from BACKEND. URL: $uriStr');
        final res = await _client.get(uri).timeout(const Duration(seconds: 4));
        
        debugPrint('[MARKET_RUNTIME] BACKEND status=${res.statusCode} response_bytes=${res.bodyBytes.length}');
        
        if (res.statusCode != 200) {
          throw Exception('backend HTTP ${res.statusCode}');
        }
        
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid backend JSON structure');
        }

        final rawIndices = decoded['indices'];
        final indices = (rawIndices is List)
            ? rawIndices
                .whereType<Map<String, dynamic>>()
                .map(MarketIndex.fromJson)
                .toList()
            : <MarketIndex>[];

        final gainers = _quotes(decoded['gainers']);
        gainers.sort((a, b) => b.changePct.compareTo(a.changePct));
        
        final losers = _quotes(decoded['losers']);
        losers.sort((a, b) => a.changePct.compareTo(b.changePct));

        debugPrint('[MARKET_RUNTIME] parsed_quotes=${gainers.length + losers.length} live_result=true');

        return MarketSnapshot(
          indices: indices,
          gainers: gainers,
          losers: losers,
          isLive: true,
          source: MarketDataSource.backend,
          fetchedAt: DateTime.now(),
        );
      } catch (e) {
        lastError = e;
        debugPrint('[MARKET_RUNTIME] BACKEND candidate $uriStr failed: $e');
      }
    }
    throw lastError ?? Exception('All backend candidates failed');
  }

  List<StockQuote> _quotes(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(StockQuote.fromJson)
        .where((q) => q.symbol.isNotEmpty && q.lastPrice > 0)
        .toList();
  }

  Future<void> _ensureNseCookie() async {
    if (_nseCookie != null) return;
    debugPrint('[MARKET_RUNTIME] handshake_started');
    try {
      final res = await _client
          .get(Uri.parse(AppConfig.nseBaseUrl), headers: _nseHeaders)
          .timeout(const Duration(seconds: 8));
      debugPrint('[MARKET_RUNTIME] handshake_status=${res.statusCode}');
      if (res.statusCode != 200) {
        throw Exception('NSE handshake failed with status ${res.statusCode}');
      }
      final setCookie = res.headers['set-cookie'];
      if (setCookie == null || setCookie.isEmpty) {
        throw Exception('no nse cookie in headers');
      }
      _nseCookie = setCookie
          .split(RegExp(r',(?=[^ ;]+=)'))
          .map((c) => c.split(';').first.trim())
          .join('; ');
    } catch (e) {
      debugPrint('[MARKET_RUNTIME] HANDSHAKE_ERROR $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _nseJson(String path) async {
    await _ensureNseCookie();
    debugPrint('[MARKET_RUNTIME] market_request_started endpoint=$path');
    try {
      final res = await _client
          .get(Uri.parse('${AppConfig.nseBaseUrl}$path'),
              headers: {..._nseHeaders, 'Cookie': _nseCookie!})
          .timeout(const Duration(seconds: 10));
      debugPrint('[MARKET_RUNTIME] market_status=${res.statusCode} response_bytes=${res.bodyBytes.length}');
      if (res.statusCode != 200) {
        _nseCookie = null;
        throw Exception('nse ${res.statusCode}');
      }
      debugPrint('[MARKET_RUNTIME] json_parse_started');
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        _nseCookie = null;
        throw const FormatException('NSE response is not a valid JSON map');
      }
      return decoded;
    } catch (e) {
      debugPrint('[MARKET_RUNTIME] NSE request error on $path: $e');
      rethrow;
    }
  }

  Future<MarketSnapshot> _fromNse() async {
    await _ensureNseCookie();

    final results = await Future.wait([
      _nseJson('/api/allIndices'),
      _nseJson('/api/equity-stockIndices?index=NIFTY%2050'),
    ]);

    final indexJson = results[0];
    final nifty = results[1];

    final rawIndexData = indexJson['data'];
    final indices = (rawIndexData is List)
        ? rawIndexData
            .whereType<Map<String, dynamic>>()
            .where((e) => _trackedIndicesSet.contains(e['index']))
            .map(MarketIndex.fromNse)
            .toList()
        : <MarketIndex>[];

    indices.sort((a, b) {
      final idxA = _trackedIndicesList.indexOf(a.name);
      final idxB = _trackedIndicesList.indexOf(b.name);
      return (idxA == -1 ? 999 : idxA).compareTo(idxB == -1 ? 999 : idxB);
    });

    final rawNiftyData = nifty['data'];
    final quotes = (rawNiftyData is List)
        ? rawNiftyData
            .whereType<Map<String, dynamic>>()
            .where((e) => e['symbol'] != 'NIFTY 50')
            .map(StockQuote.fromNse)
            .where((q) =>
                q.symbol.isNotEmpty &&
                q.lastPrice > 0 &&
                !q.changePct.isNaN &&
                !q.changePct.isInfinite)
            .toList()
        : <StockQuote>[];

    final gainers = List<StockQuote>.from(quotes);
    gainers.sort((a, b) => b.changePct.compareTo(a.changePct));

    final losers = List<StockQuote>.from(quotes);
    losers.sort((a, b) => a.changePct.compareTo(b.changePct));

    if (indices.isEmpty && quotes.isEmpty) {
      throw Exception('NSE response empty or malformed');
    }

    debugPrint('[MARKET_RUNTIME] parsed_quotes=${quotes.length} live_result=true');
    if (quotes.isNotEmpty) {
      debugPrint('[MARKET_RUNTIME] first_symbols=${quotes.take(3).map((q) => q.symbol).join(', ')}');
    }

    return MarketSnapshot(
      indices: indices,
      gainers: gainers.take(5).toList(),
      losers: losers.take(5).toList(),
      isLive: true,
      source: MarketDataSource.nse,
      fetchedAt: DateTime.now(),
    );
  }
}
