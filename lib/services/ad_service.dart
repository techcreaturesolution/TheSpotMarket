import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';

/// Wraps Google AdMob. Banner ads live on most screens, an interstitial fires
/// every N detail views and a native ad is injected into the news list.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitial;
  int _detailViews = 0;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static AdRequest get request => const AdRequest(
        keywords: AppConfig.adKeywords,
        contentUrl: 'https://www.nseindia.com',
        nonPersonalizedAds: false,
      );

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
      ),
    );
    _initialized = true;
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Call whenever the user opens an IPO / news detail. Shows an interstitial
  /// on every [AppConfig.interstitialFrequency]-th call.
  void recordDetailView() {
    _detailViews++;
    if (_detailViews % AppConfig.interstitialFrequency != 0) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
    _interstitial = null;
  }

  BannerAd createBanner({AdSize size = AdSize.banner, void Function()? onLoaded, void Function()? onFailed}) =>
      BannerAd(
        adUnitId: AppConfig.bannerAdUnitId,
        size: size,
        request: request,
        listener: BannerAdListener(
          onAdLoaded: (_) => onLoaded?.call(),
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            onFailed?.call();
          },
        ),
      );

  NativeAd createNative({required void Function(Ad) onLoaded, required void Function() onFailed}) =>
      NativeAd(
        adUnitId: AppConfig.nativeAdUnitId,
        request: request,
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          cornerRadius: 12,
        ),
        listener: NativeAdListener(
          onAdLoaded: onLoaded,
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            onFailed();
          },
        ),
      );
}
