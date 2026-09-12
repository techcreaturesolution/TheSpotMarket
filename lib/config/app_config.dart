import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central configuration. Values can be overridden at build time with
/// `--dart-define=KEY=VALUE` so secrets never need to be committed.
class AppConfig {
  AppConfig._();

  static const appName = 'TheSpotMarket';
  static const tagline = 'IPO, Stocks & Market Intelligence';

  /// Optional backend that aggregates IPO / market data
  /// (e.g. a small Node/Python API you host). When empty the app falls back
  /// to public sources and bundled sample data.
  static const backendBaseUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');

  /// AI provider. Supported: `gemini` (default) or `openai`.
  static const aiProvider =
      String.fromEnvironment('AI_PROVIDER', defaultValue: 'gemini');
  static const aiApiKey = String.fromEnvironment('AI_API_KEY', defaultValue: '');
  static const geminiModel =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-1.5-flash');
  static const openAiModel =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');

  // ---------------------------------------------------------------------------
  // AdMob. Test IDs are used in debug builds; production IDs come from
  // --dart-define so the same code base ships to Play Store / App Store.
  // ---------------------------------------------------------------------------
  static const _admobBannerAndroid = String.fromEnvironment(
      'ADMOB_BANNER_ANDROID',
      defaultValue: 'ca-app-pub-3940256099942544/6300978111');
  static const _admobBannerIos = String.fromEnvironment('ADMOB_BANNER_IOS',
      defaultValue: 'ca-app-pub-3940256099942544/2934735716');
  static const _admobInterstitialAndroid = String.fromEnvironment(
      'ADMOB_INTERSTITIAL_ANDROID',
      defaultValue: 'ca-app-pub-3940256099942544/1033173712');
  static const _admobInterstitialIos = String.fromEnvironment(
      'ADMOB_INTERSTITIAL_IOS',
      defaultValue: 'ca-app-pub-3940256099942544/4411468910');
  static const _admobNativeAndroid = String.fromEnvironment(
      'ADMOB_NATIVE_ANDROID',
      defaultValue: 'ca-app-pub-3940256099942544/2247696110');
  static const _admobNativeIos = String.fromEnvironment('ADMOB_NATIVE_IOS',
      defaultValue: 'ca-app-pub-3940256099942544/3986624511');

  static bool get _isIos => !kIsWeb && Platform.isIOS;

  static String get bannerAdUnitId =>
      _isIos ? _admobBannerIos : _admobBannerAndroid;
  static String get interstitialAdUnitId =>
      _isIos ? _admobInterstitialIos : _admobInterstitialAndroid;
  static String get nativeAdUnitId =>
      _isIos ? _admobNativeIos : _admobNativeAndroid;

  /// Keywords passed to AdMob so served ads skew towards finance / business /
  /// startup content, which pays better CPMs for this audience.
  static const adKeywords = <String>[
    'stock market',
    'share market',
    'IPO',
    'demat account',
    'mutual funds',
    'trading',
    'business loan',
    'startup',
    'new business',
    'investment',
    'NSE',
    'BSE',
  ];

  /// Interstitial shown after this many IPO / news detail views.
  static const interstitialFrequency = 4;

  // ---------------------------------------------------------------------------
  // Public data sources
  // ---------------------------------------------------------------------------
  static const nseBaseUrl = 'https://www.nseindia.com';

  static const newsFeeds = <NewsFeed>[
    NewsFeed('Economic Times - Markets',
        'https://economictimes.indiatimes.com/markets/rssfeeds/1977021501.cms'),
    NewsFeed('Economic Times - Stocks',
        'https://economictimes.indiatimes.com/markets/stocks/rssfeeds/2146842.cms'),
    NewsFeed('Economic Times - IPOs',
        'https://economictimes.indiatimes.com/markets/ipos/fpos/rssfeeds/14655708.cms'),
    NewsFeed('Moneycontrol - Markets',
        'https://www.moneycontrol.com/rss/marketreports.xml'),
    NewsFeed('Moneycontrol - Business',
        'https://www.moneycontrol.com/rss/business.xml'),
    NewsFeed('Livemint - Markets',
        'https://www.livemint.com/rss/markets'),
    NewsFeed('Business Standard - Markets',
        'https://www.business-standard.com/rss/markets-106.rss'),
  ];

  static const registrars = <Registrar>[
    Registrar(
      'Link Intime (MUFG Intime)',
      'https://linkintime.co.in/Initial_Offer/public-issues.html',
    ),
    Registrar(
      'KFin Technologies',
      'https://kosmic.kfintech.com/ipostatus/',
    ),
    Registrar(
      'Bigshare Services',
      'https://ipo.bigshareonline.com/IPO_Status.html',
    ),
    Registrar(
      'Cameo Corporate Services',
      'https://ipostatus1.cameoindia.com/',
    ),
    Registrar(
      'Skyline Financial',
      'https://www.skylinerta.com/ipo.php',
    ),
    Registrar(
      'Maashitla Securities',
      'https://maashitla.com/allotment-status/public-issues',
    ),
    Registrar(
      'Purva Sharegistry',
      'https://www.purvashare.com/investor-service/ipo-query',
    ),
    Registrar(
      'BSE IPO Status',
      'https://www.bseindia.com/investors/appli_check.aspx',
    ),
  ];
}

class NewsFeed {
  const NewsFeed(this.name, this.url);
  final String name;
  final String url;
}

class Registrar {
  const Registrar(this.name, this.url);
  final String name;
  final String url;
}
