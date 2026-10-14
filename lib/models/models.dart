import 'package:flutter/material.dart';

double _numToDouble(dynamic v) {
  if (v is num) {
    final d = v.toDouble();
    return (d.isNaN || d.isInfinite) ? 0.0 : d;
  }
  if (v is String) {
    final clean = v.replaceAll(',', '').trim();
    final d = double.tryParse(clean) ?? 0.0;
    return (d.isNaN || d.isInfinite) ? 0.0 : d;
  }
  return 0.0;
}

double? _numToNullableDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) {
    final d = v.toDouble();
    return (d.isNaN || d.isInfinite) ? null : d;
  }
  if (v is String) {
    final clean = v.replaceAll(',', '').trim();
    final d = double.tryParse(clean);
    if (d == null || d.isNaN || d.isInfinite) return null;
    return d;
  }
  return null;
}



int? _numToNullableInt(dynamic v) {
  if (v == null) return null;
  if (v is num) {
    if (v.isNaN || v.isInfinite) return null;
    return v.toInt();
  }
  if (v is String) {
    final clean = v.replaceAll(',', '').trim();
    return int.tryParse(clean);
  }
  return null;
}

enum MarketDataSource {
  nse,
  backend,
  yahoo,
  sampleFallback,
  unknown,
  indianApi,
}

extension MarketDataSourceX on MarketDataSource {
  String get label => switch (this) {
        MarketDataSource.nse => 'NSE LIVE',
        MarketDataSource.backend => 'BACKEND',
        MarketDataSource.yahoo => 'YAHOO',
        MarketDataSource.indianApi => 'IndianAPI',
        MarketDataSource.sampleFallback => 'DEMO DATA',
        MarketDataSource.unknown => 'UNKNOWN',
      };

  bool get isRealMarket => this == MarketDataSource.nse || this == MarketDataSource.backend;
}

enum IpoStatus { upcoming, open, closed, listed }

extension IpoStatusX on IpoStatus {
  String get label => switch (this) {
        IpoStatus.upcoming => 'Upcoming',
        IpoStatus.open => 'Open',
        IpoStatus.closed => 'Closed',
        IpoStatus.listed => 'Listed',
      };

  Color get color => switch (this) {
        IpoStatus.upcoming => Colors.blue,
        IpoStatus.open => Colors.green,
        IpoStatus.closed => Colors.orange,
        IpoStatus.listed => Colors.purple,
      };
}

class Ipo {
  const Ipo({
    required this.id,
    required this.name,
    required this.symbol,
    required this.exchange,
    required this.sector,
    this.openDate,
    this.closeDate,
    this.allotmentDate,
    this.listingDate,
    required this.priceMin,
    required this.priceMax,
    this.issuePrice,
    this.lotSize,
    required this.issueSizeCr,
    required this.registrar,
    required this.registrarUrl,
    required this.about,
    this.subscriptionQib,
    this.subscriptionNii,
    this.subscriptionRetail,
    this.gmp,
    this.listingPrice,
    this.isSme = false,
    this.providerStatus,
  });

  final String id;
  final String name;
  final String symbol;
  final String exchange;
  final String sector;
  final DateTime? openDate;
  final DateTime? closeDate;
  final DateTime? allotmentDate;
  final DateTime? listingDate;
  final double priceMin;
  final double priceMax;
  final double? issuePrice;
  final int? lotSize;
  final double issueSizeCr;
  final String registrar;
  final String registrarUrl;
  final String about;
  final double? subscriptionQib;
  final double? subscriptionNii;
  final double? subscriptionRetail;
  final double? gmp;
  final double? listingPrice;
  final bool isSme;
  final IpoStatus? providerStatus;

  IpoStatus statusOn(DateTime now) {
    // An IPO cannot logically be "Open" without definitive opening/closing calendar dates.
    if (providerStatus == IpoStatus.open) {
      if (openDate == null || closeDate == null) {
        return IpoStatus.upcoming;
      }
      if (now.isBefore(openDate!)) return IpoStatus.upcoming;
      final closeEndOfDay = DateTime(closeDate!.year, closeDate!.month, closeDate!.day, 23, 59, 59);
      if (now.isAfter(closeEndOfDay)) {
        if (listingDate != null && now.isAfter(listingDate!)) return IpoStatus.listed;
        return IpoStatus.closed;
      }
      return IpoStatus.open;
    }
    if (providerStatus != null) return providerStatus!;
    if (openDate == null || closeDate == null) return IpoStatus.upcoming;
    if (now.isBefore(openDate!)) return IpoStatus.upcoming;
    final closeEndOfDay = DateTime(closeDate!.year, closeDate!.month, closeDate!.day, 23, 59, 59);
    if (!now.isAfter(closeEndOfDay)) return IpoStatus.open;
    if (listingDate != null && now.isBefore(listingDate!)) return IpoStatus.closed;
    if (listingDate == null && now.isAfter(closeEndOfDay)) return IpoStatus.closed;
    return IpoStatus.listed;
  }

  IpoStatus get status => statusOn(DateTime.now());

  double get totalSubscription {
    final parts = [subscriptionQib, subscriptionNii, subscriptionRetail]
        .whereType<double>()
        .toList();
    if (parts.isEmpty) return 0;
    return parts.reduce((a, b) => a + b) / parts.length;
  }

  double get minInvestment =>
      lotSize != null && lotSize! > 0 && priceMax > 0 ? priceMax * lotSize! : 0.0;

  double? get expectedListingGainPct =>
      gmp == null || priceMax == 0 ? null : (gmp! / priceMax) * 100;

  factory Ipo.fromJson(Map<String, dynamic> j) => Ipo(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        exchange: (j['exchange'] ?? 'NSE, BSE').toString(),
        sector: (j['sector'] ?? 'Other').toString(),
        openDate: j['openDate'] != null ? DateTime.tryParse(j['openDate'].toString()) : null,
        closeDate: j['closeDate'] != null ? DateTime.tryParse(j['closeDate'].toString()) : null,
        allotmentDate: j['allotmentDate'] != null ? DateTime.tryParse(j['allotmentDate'].toString()) : null,
        listingDate: j['listingDate'] != null ? DateTime.tryParse(j['listingDate'].toString()) : null,
        priceMin: _numToDouble(j['priceMin']),
        priceMax: _numToDouble(j['priceMax']),
        issuePrice: _numToNullableDouble(j['issuePrice']),
        lotSize: _numToNullableInt(j['lotSize']),
        issueSizeCr: _numToDouble(j['issueSizeCr']),
        registrar: (j['registrar'] ?? '').toString(),
        registrarUrl: (j['registrarUrl'] ?? '').toString(),
        about: (j['about'] ?? '').toString(),
        subscriptionQib: _numToNullableDouble(j['subscriptionQib']),
        subscriptionNii: _numToNullableDouble(j['subscriptionNii']),
        subscriptionRetail: _numToNullableDouble(j['subscriptionRetail']),
        gmp: _numToNullableDouble(j['gmp']),
        listingPrice: _numToNullableDouble(j['listingPrice']),
        isSme: j['isSme'] == true || (j['isSme']?.toString().toLowerCase() == 'true'),
        providerStatus: _parseState(j['state']?.toString()),
      );

  static IpoStatus? _parseState(String? s) {
    if (s == null) return null;
    switch (s.toUpperCase()) {
      case 'UPCOMING': return IpoStatus.upcoming;
      case 'OPEN': return IpoStatus.open;
      case 'CLOSED': return IpoStatus.closed;
      case 'LISTED': return IpoStatus.listed;
      default: return null;
    }
  }
}

class MarketIndex {
  const MarketIndex({
    required this.name,
    required this.exchange,
    required this.last,
    required this.change,
    required this.changePct,
    this.open,
    this.high,
    this.low,
    this.previousClose,
    this.sparkline = const [],
  });

  final String name;
  final String exchange;
  final double last;
  final double change;
  final double changePct;
  final double? open;
  final double? high;
  final double? low;
  final double? previousClose;
  final List<double> sparkline;

  bool get isUp => change >= 0;

  MarketIndex copyWith({
    String? name,
    String? exchange,
    double? last,
    double? change,
    double? changePct,
    double? open,
    double? high,
    double? low,
    double? previousClose,
    List<double>? sparkline,
  }) =>
      MarketIndex(
        name: name ?? this.name,
        exchange: exchange ?? this.exchange,
        last: last ?? this.last,
        change: change ?? this.change,
        changePct: changePct ?? this.changePct,
        open: open ?? this.open,
        high: high ?? this.high,
        low: low ?? this.low,
        previousClose: previousClose ?? this.previousClose,
        sparkline: sparkline ?? this.sparkline,
      );

  factory MarketIndex.fromJson(Map<String, dynamic> e) => MarketIndex(
        name: (e['name'] ?? '').toString(),
        exchange: e['exchange'] as String? ?? 'NSE',
        last: _numToDouble(e['last']),
        change: _numToDouble(e['change']),
        changePct: _numToDouble(e['changePct']),
        open: _numToNullableDouble(e['open']),
        high: _numToNullableDouble(e['high']),
        low: _numToNullableDouble(e['low']),
        previousClose: _numToNullableDouble(e['previousClose']),
        sparkline: ((e['sparkline'] as List?) ?? const [])
            .map(_numToDouble)
            .toList(),
      );

  factory MarketIndex.fromNse(Map<String, dynamic> j) {
    final last = _numToDouble(j['last']);
    final change = _numToDouble(j['variation']);
    return MarketIndex(
      name: (j['index'] ?? '').toString(),
      exchange: 'NSE',
      last: last,
      change: change,
      changePct: _numToDouble(j['percentChange']),
      open: _numToNullableDouble(j['open']),
      high: _numToNullableDouble(j['high']),
      low: _numToNullableDouble(j['low']),
      previousClose: _numToNullableDouble(j['previousClose']),
    );
  }
}

class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.name,
    required this.lastPrice,
    required this.change,
    required this.changePct,
    this.volume,
    this.sector,
    this.currency = '₹',
    this.sparkline = const [],
  });

  final String symbol;
  final String name;
  final double lastPrice;
  final double change;
  final double changePct;
  final int? volume;
  final String? sector;
  final String currency;
  final List<double> sparkline;

  bool get isUp => change >= 0;

  factory StockQuote.fromJson(Map<String, dynamic> e) => StockQuote(
        symbol: (e['symbol'] ?? '').toString(),
        name: (e['name'] ?? e['symbol'] ?? '').toString(),
        lastPrice: _numToDouble(e['lastPrice']),
        change: _numToDouble(e['change']),
        changePct: _numToDouble(e['changePct']),
        volume: _numToNullableInt(e['volume']),
        sector: e['sector'] as String?,
        currency: e['currency'] as String? ?? '₹',
        sparkline: ((e['sparkline'] as List?) ?? const [])
            .map(_numToDouble)
            .toList(),
      );

  factory StockQuote.fromNse(Map<String, dynamic> j) {
    final meta = j['meta'] is Map ? (j['meta'] as Map) : null;
    final companyName = meta?['companyName']?.toString();
    final industry = meta?['industry']?.toString();
    final symbol = (j['symbol'] ?? '').toString();

    return StockQuote(
      symbol: symbol,
      name: (companyName != null && companyName.isNotEmpty)
          ? companyName
          : symbol,
      lastPrice: _numToDouble(j['lastPrice']),
      change: _numToDouble(j['change']),
      changePct: _numToDouble(j['pChange']),
      volume: _numToNullableInt(j['totalTradedVolume']),
      sector: (industry != null && industry.isNotEmpty) ? industry : null,
    );
  }
}

enum TradeAction { buy, sell, hold }

extension TradeActionX on TradeAction {
  String get label => switch (this) {
        TradeAction.buy => 'BUY',
        TradeAction.sell => 'SELL',
        TradeAction.hold => 'HOLD',
      };

  Color get color => switch (this) {
        TradeAction.buy => Colors.green,
        TradeAction.sell => Colors.red,
        TradeAction.hold => Colors.orange,
      };
}

/// AI-derived trade idea for a stock. Informational only, not investment advice.
class StockSuggestion {
  const StockSuggestion({
    required this.quote,
    required this.action,
    required this.confidence,
    required this.reasons,
    required this.target,
    required this.stopLoss,
    this.horizon = 'Short term (1–2 weeks)',
  });

  final StockQuote quote;
  final TradeAction action;

  /// 0–100
  final int confidence;
  final List<String> reasons;
  final double target;
  final double stopLoss;
  final String horizon;
}

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.link,
    required this.source,
    required this.publishedAt,
    this.description,
    this.imageUrl,
  });

  final String title;
  final String link;
  final String source;
  final DateTime publishedAt;
  final String? description;
  final String? imageUrl;

  String get category {
    final t = '$title ${description ?? ''}'.toLowerCase();
    if (t.contains('ipo')) return 'IPO';
    if (t.contains('nifty') || t.contains('sensex')) return 'Indices';
    if (t.contains('bse')) return 'BSE';
    if (t.contains('nse')) return 'NSE';
    if (t.contains('rbi') || t.contains('rupee') || t.contains('inflation')) {
      return 'Economy';
    }
    if (t.contains('startup') || t.contains('business')) return 'Business';
    return 'Stocks';
  }
}

class PanProfile {
  const PanProfile({
    required this.id,
    required this.name,
    required this.pan,
    this.applicationNumber,
    this.dpId,
  });

  final String id;
  final String name;
  final String pan;
  final String? applicationNumber;
  final String? dpId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pan': pan,
        'applicationNumber': applicationNumber,
        'dpId': dpId,
      };

  factory PanProfile.fromJson(Map<String, dynamic> j) => PanProfile(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        pan: (j['pan'] ?? '').toString().toUpperCase().trim(),
        applicationNumber: j['applicationNumber']?.toString(),
        dpId: j['dpId']?.toString(),
      );

  PanProfile copyWith({String? name, String? pan, String? applicationNumber, String? dpId}) =>
      PanProfile(
        id: id,
        name: name ?? this.name,
        pan: pan ?? this.pan,
        applicationNumber: applicationNumber ?? this.applicationNumber,
        dpId: dpId ?? this.dpId,
      );

  static final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static bool isValidPan(String value) => panRegex.hasMatch(value.toUpperCase());
}

enum AllotmentOutcome { allotted, notAllotted, pending, unknown }

class AllotmentResult {
  const AllotmentResult({
    required this.profileId,
    required this.ipoId,
    required this.outcome,
    required this.checkedAt,
    this.sharesAllotted,
    this.note,
  });

  final String profileId;
  final String ipoId;
  final AllotmentOutcome outcome;
  final DateTime checkedAt;
  final int? sharesAllotted;
  final String? note;

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'ipoId': ipoId,
        'outcome': outcome.name,
        'checkedAt': checkedAt.toIso8601String(),
        'sharesAllotted': sharesAllotted,
        'note': note,
      };

  factory AllotmentResult.fromJson(Map<String, dynamic> j) {
    final rawOutcome = (j['outcome'] ?? '').toString();
    final outcome = AllotmentOutcome.values.firstWhere(
      (e) => e.name == rawOutcome,
      orElse: () => AllotmentOutcome.unknown,
    );
    final rawCheckedAt = j['checkedAt']?.toString() ?? '';
    final checkedAt = DateTime.tryParse(rawCheckedAt) ?? DateTime.now();

    return AllotmentResult(
      profileId: (j['profileId'] ?? '').toString(),
      ipoId: (j['ipoId'] ?? '').toString(),
      outcome: outcome,
      checkedAt: checkedAt,
      sharesAllotted: _numToNullableInt(j['sharesAllotted']),
      note: j['note']?.toString(),
    );
  }

  String get key => '$profileId|$ipoId';
}

class ChatMessage {
  const ChatMessage({required this.role, required this.text, required this.at});
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime at;
  bool get isUser => role == 'user';
}
