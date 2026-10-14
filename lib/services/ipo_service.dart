import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';
import 'sample_data.dart';

class IpoFeed {
  IpoFeed({
    required this.ipos,
    required this.isLive,
    DateTime? fetchedAt,
    this.source = MarketDataSource.unknown,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  final List<Ipo> ipos;
  final bool isLive;
  final DateTime fetchedAt;
  final MarketDataSource source;

  int get length => ipos.length;
  bool get isEmpty => ipos.isEmpty;
  bool get isNotEmpty => ipos.isNotEmpty;
  Ipo operator [](int index) => ipos[index];
  Ipo get first => ipos.first;
  bool any(bool Function(Ipo element) test) => ipos.any(test);
}

/// IPO calendar + subscription figures.
///
/// Order of preference:
/// 1. Configured backend (`BACKEND_URL/ipos`) scraping official sources.
/// 2. Live NSE India public APIs (`/api/ipo-current-issue`, `/api/all-upcoming-issues`).
/// 3. Bundled fallback data with live status flag set to false.
class IpoService {
  IpoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<IpoFeed> fetchIpos() async {
    final candidateUrls = [
      '${AppConfig.backendBaseUrl}/ipos',
      if (AppConfig.backendBaseUrl.contains('127.0.0.1') || AppConfig.backendBaseUrl.contains('localhost')) ...[
        'http://192.168.29.254:3000/ipos',
        'http://10.0.2.2:3000/ipos',
      ]
    ];

    for (final uriStr in candidateUrls) {
      try {
        final res = await _client.get(Uri.parse(uriStr)).timeout(const Duration(seconds: 4));
        
        if (res.statusCode == 200 || res.statusCode == 503) {
          final dynamic body = jsonDecode(res.body);
          final bool isLive = body['isLive'] == true;
          final String sourceStr = body['source']?.toString() ?? 'BACKEND';
          
          MarketDataSource source = MarketDataSource.backend;
          if (sourceStr == 'IndianAPI') {
            source = MarketDataSource.indianApi;
          } else if (sourceStr == 'NSE') {
            source = MarketDataSource.nse;
          }
          
          final List rawList = body['data'] is List ? body['data'] as List : [];
          final ipos = <Ipo>[];
          final seenIds = <String>{};
          
          for (final item in rawList) {
            if (item is Map<String, dynamic>) {
              // Note: we can trust the 'state' provided by the backend to map to Flutter's status
              final ipo = Ipo.fromJson(item);
              final key = ipo.id.isNotEmpty ? ipo.id : ipo.symbol;
              if (key.isNotEmpty && seenIds.add(key.toLowerCase())) {
                ipos.add(ipo);
              }
            }
          }
          
          if (ipos.isNotEmpty) {
            final feed = IpoFeed(
              ipos: _sorted(ipos),
              isLive: isLive,
              fetchedAt: DateTime.now(),
              source: source,
            );
            _logFeed(feed);
            return feed;
          }
        }
      } catch (_) {}
    }

    final fallbackFeed = IpoFeed(
      ipos: _sorted(SampleData.ipos()),
      isLive: false,
      fetchedAt: DateTime.now(),
      source: MarketDataSource.sampleFallback,
    );
    _logFeed(fallbackFeed);
    return fallbackFeed;
  }



  void _logFeed(IpoFeed feed) {
    if (kDebugMode) {
      debugPrint(
          '[IPO_DATA] source=${feed.source.label} status=${feed.isLive ? "LIVE" : "DEMO"} count=${feed.ipos.length} fetchedAt=${feed.fetchedAt}');
    }
  }



  List<Ipo> _sorted(List<Ipo> list) {
    // 1. Deduplicate by unique id or symbol (case-insensitive)
    final seenKeys = <String>{};
    final unique = <Ipo>[];
    for (final item in list) {
      final key = item.id.isNotEmpty ? item.id.toLowerCase() : item.symbol.toLowerCase();
      if (key.isNotEmpty && seenKeys.add(key)) {
        unique.add(item);
      }
    }

    const order = {
      IpoStatus.open: 0,
      IpoStatus.upcoming: 1,
      IpoStatus.closed: 2,
      IpoStatus.listed: 3,
    };

    final now = DateTime.now();
    unique.sort((a, b) {
      final statusA = a.statusOn(now);
      final statusB = b.statusOn(now);
      final s = order[statusA]!.compareTo(order[statusB]!);
      if (s != 0) return s;

      // Within upcoming, sort by nearest openDate ascending
      if (statusA == IpoStatus.upcoming) {
        if (a.openDate == null && b.openDate == null) return 0;
        if (a.openDate == null) return 1;
        if (b.openDate == null) return -1;
        return a.openDate!.compareTo(b.openDate!);
      }
      // Within open, sort by nearest closeDate ascending
      if (statusA == IpoStatus.open) {
        if (a.closeDate == null && b.closeDate == null) return 0;
        if (a.closeDate == null) return 1;
        if (b.closeDate == null) return -1;
        return a.closeDate!.compareTo(b.closeDate!);
      }
      
      if (a.openDate == null && b.openDate == null) return 0;
      if (a.openDate == null) return 1;
      if (b.openDate == null) return -1;
      return a.openDate!.compareTo(b.openDate!);
    });

    return unique;
  }
}

