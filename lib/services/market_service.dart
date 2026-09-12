import 'dart:convert';

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
  });

  final List<MarketIndex> indices;
  final List<StockQuote> gainers;
  final List<StockQuote> losers;
  final bool isLive;
  final DateTime fetchedAt;
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

  static const _nseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9',
    'Referer': 'https://www.nseindia.com/',
  };

  static const _trackedIndices = {
    'NIFTY 50',
    'NIFTY BANK',
    'NIFTY IT',
    'NIFTY MIDCAP 100',
    'NIFTY NEXT 50',
    'INDIA VIX',
  };

  Future<MarketSnapshot> fetchSnapshot() async {
    if (AppConfig.backendBaseUrl.isNotEmpty) {
      try {
        return await _fromBackend();
      } catch (_) {}
    }
    try {
      return await _fromNse();
    } catch (_) {
      return MarketSnapshot(
        indices: SampleData.indices(),
        gainers: SampleData.gainers(),
        losers: SampleData.losers(),
        isLive: false,
        fetchedAt: DateTime.now(),
      );
    }
  }

  Future<MarketSnapshot> _fromBackend() async {
    final res = await _client
        .get(Uri.parse('${AppConfig.backendBaseUrl}/market/snapshot'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('backend ${res.statusCode}');
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return MarketSnapshot(
      indices: (j['indices'] as List)
          .cast<Map<String, dynamic>>()
          .map(MarketIndex.fromJson)
          .toList(),
      gainers: _quotes(j['gainers']),
      losers: _quotes(j['losers']),
      isLive: true,
      fetchedAt: DateTime.now(),
    );
  }

  List<StockQuote> _quotes(Object? raw) => ((raw as List?) ?? const [])
      .cast<Map<String, dynamic>>()
      .map(StockQuote.fromJson)
      .toList();

  Future<void> _ensureNseCookie() async {
    if (_nseCookie != null) return;
    final res = await _client
        .get(Uri.parse(AppConfig.nseBaseUrl), headers: _nseHeaders)
        .timeout(const Duration(seconds: 8));
    final setCookie = res.headers['set-cookie'];
    if (setCookie == null) throw Exception('no nse cookie');
    _nseCookie = setCookie
        .split(RegExp(r',(?=[^ ;]+=)'))
        .map((c) => c.split(';').first.trim())
        .join('; ');
  }

  Future<Map<String, dynamic>> _nseJson(String path) async {
    await _ensureNseCookie();
    final res = await _client
        .get(Uri.parse('${AppConfig.nseBaseUrl}$path'),
            headers: {..._nseHeaders, 'Cookie': _nseCookie!})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      _nseCookie = null;
      throw Exception('nse ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<MarketSnapshot> _fromNse() async {
    final indexJson = await _nseJson('/api/allIndices');
    final indices = (indexJson['data'] as List)
        .cast<Map<String, dynamic>>()
        .where((e) => _trackedIndices.contains(e['index']))
        .map(MarketIndex.fromNse)
        .toList()
      ..sort((a, b) => _trackedIndices
          .toList()
          .indexOf(a.name)
          .compareTo(_trackedIndices.toList().indexOf(b.name)));

    final nifty = await _nseJson('/api/equity-stockIndices?index=NIFTY%2050');
    final quotes = (nifty['data'] as List)
        .cast<Map<String, dynamic>>()
        .where((e) => e['symbol'] != 'NIFTY 50')
        .map(StockQuote.fromNse)
        .toList()
      ..sort((a, b) => b.changePct.compareTo(a.changePct));

    return MarketSnapshot(
      indices: indices,
      gainers: quotes.take(5).toList(),
      losers: quotes.reversed.take(5).toList(),
      isLive: true,
      fetchedAt: DateTime.now(),
    );
  }
}
