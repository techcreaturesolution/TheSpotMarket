import 'package:flutter/material.dart';

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
    required this.openDate,
    required this.closeDate,
    required this.allotmentDate,
    required this.listingDate,
    required this.priceMin,
    required this.priceMax,
    required this.lotSize,
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
  });

  final String id;
  final String name;
  final String symbol;
  final String exchange;
  final String sector;
  final DateTime openDate;
  final DateTime closeDate;
  final DateTime allotmentDate;
  final DateTime listingDate;
  final double priceMin;
  final double priceMax;
  final int lotSize;
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

  IpoStatus statusOn(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(openDate)) return IpoStatus.upcoming;
    if (!today.isAfter(closeDate)) return IpoStatus.open;
    if (today.isBefore(listingDate)) return IpoStatus.closed;
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

  double get minInvestment => priceMax * lotSize;

  double? get expectedListingGainPct =>
      gmp == null || priceMax == 0 ? null : (gmp! / priceMax) * 100;

  factory Ipo.fromJson(Map<String, dynamic> j) => Ipo(
        id: j['id'] as String,
        name: j['name'] as String,
        symbol: j['symbol'] as String? ?? '',
        exchange: j['exchange'] as String? ?? 'NSE, BSE',
        sector: j['sector'] as String? ?? 'Other',
        openDate: DateTime.parse(j['openDate'] as String),
        closeDate: DateTime.parse(j['closeDate'] as String),
        allotmentDate: DateTime.parse(j['allotmentDate'] as String),
        listingDate: DateTime.parse(j['listingDate'] as String),
        priceMin: (j['priceMin'] as num).toDouble(),
        priceMax: (j['priceMax'] as num).toDouble(),
        lotSize: j['lotSize'] as int,
        issueSizeCr: (j['issueSizeCr'] as num).toDouble(),
        registrar: j['registrar'] as String? ?? '',
        registrarUrl: j['registrarUrl'] as String? ?? '',
        about: j['about'] as String? ?? '',
        subscriptionQib: (j['subscriptionQib'] as num?)?.toDouble(),
        subscriptionNii: (j['subscriptionNii'] as num?)?.toDouble(),
        subscriptionRetail: (j['subscriptionRetail'] as num?)?.toDouble(),
        gmp: (j['gmp'] as num?)?.toDouble(),
        listingPrice: (j['listingPrice'] as num?)?.toDouble(),
        isSme: j['isSme'] as bool? ?? false,
      );
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

  factory MarketIndex.fromNse(Map<String, dynamic> j) {
    final last = (j['last'] as num).toDouble();
    final change = (j['variation'] as num).toDouble();
    return MarketIndex(
      name: j['index'] as String,
      exchange: 'NSE',
      last: last,
      change: change,
      changePct: (j['percentChange'] as num).toDouble(),
      open: (j['open'] as num?)?.toDouble(),
      high: (j['high'] as num?)?.toDouble(),
      low: (j['low'] as num?)?.toDouble(),
      previousClose: (j['previousClose'] as num?)?.toDouble(),
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
  });

  final String symbol;
  final String name;
  final double lastPrice;
  final double change;
  final double changePct;
  final int? volume;
  final String? sector;

  bool get isUp => change >= 0;

  factory StockQuote.fromNse(Map<String, dynamic> j) => StockQuote(
        symbol: j['symbol'] as String,
        name: (j['meta'] as Map<String, dynamic>?)?['companyName'] as String? ??
            j['symbol'] as String,
        lastPrice: (j['lastPrice'] as num).toDouble(),
        change: (j['change'] as num).toDouble(),
        changePct: (j['pChange'] as num).toDouble(),
        volume: (j['totalTradedVolume'] as num?)?.toInt(),
        sector: (j['meta'] as Map<String, dynamic>?)?['industry'] as String?,
      );
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
        id: j['id'] as String,
        name: j['name'] as String,
        pan: j['pan'] as String,
        applicationNumber: j['applicationNumber'] as String?,
        dpId: j['dpId'] as String?,
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

  factory AllotmentResult.fromJson(Map<String, dynamic> j) => AllotmentResult(
        profileId: j['profileId'] as String,
        ipoId: j['ipoId'] as String,
        outcome: AllotmentOutcome.values.byName(j['outcome'] as String),
        checkedAt: DateTime.parse(j['checkedAt'] as String),
        sharesAllotted: j['sharesAllotted'] as int?,
        note: j['note'] as String?,
      );

  String get key => '$profileId|$ipoId';
}

class ChatMessage {
  const ChatMessage({required this.role, required this.text, required this.at});
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime at;
  bool get isUser => role == 'user';
}
