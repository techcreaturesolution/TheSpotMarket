import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/ai_service.dart';
import '../services/allotment_service.dart';
import '../services/global_market_service.dart';
import '../services/ipo_service.dart';
import '../services/market_service.dart';
import '../services/news_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.storage,
    MarketService? market,
    IpoService? ipo,
    NewsService? news,
    AllotmentService? allotment,
    AiService? ai,
    GlobalMarketService? global,
  })  : _market = market ?? MarketService(),
        _global = global ?? GlobalMarketService(),
        _ipo = ipo ?? IpoService(),
        _news = news ?? NewsService(),
        allotmentService = allotment ?? AllotmentService(),
        ai = ai ?? AiService() {
    _profiles = List<PanProfile>.from(storage.loadProfiles());
    _allotments = {for (final r in storage.loadAllotments()) r.key: r};
    _watchlist = storage.loadWatchlist();
    _darkMode = storage.darkMode;
    _chat = storage.loadChat();
    final key = storage.aiApiKey;
    if (key != null && key.isNotEmpty) this.ai.apiKey = key;
    final provider = storage.aiProvider;
    if (provider != null) this.ai.provider = provider;
  }

  final StorageService storage;
  final MarketService _market;
  final GlobalMarketService _global;
  final IpoService _ipo;
  final NewsService _news;
  final AllotmentService allotmentService;
  final AiService ai;

  Timer? _autoRefreshTimer;
  Timer? _liveTickerTimer;
  bool _isRefreshRunning = false;
  bool _disposed = false;
  final math.Random _rnd = math.Random();

  void startAutoRefresh({Duration interval = const Duration(seconds: 15)}) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) => refreshAllSilently());
    _startLiveMarketTicker();
  }

  void _startLiveMarketTicker() {
    _liveTickerTimer?.cancel();
    _liveTickerTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickLiveMarketIndices());
  }

  void _tickLiveMarketIndices() {
    if (_disposed) return;
    final current = _snapshot;
    if (current == null || current.indices.isEmpty) return;

    final updatedIndices = <MarketIndex>[];
    for (final idx in current.indices) {
      final direction = _rnd.nextBool() ? 1.0 : -1.0;
      final stepMagnitude = (idx.last * 0.00006) + (_rnd.nextDouble() * 0.35);
      final delta = double.parse((direction * stepMagnitude).toStringAsFixed(2));
      final newLast = double.parse((idx.last + delta).toStringAsFixed(2));
      final prevClose = idx.previousClose ?? idx.open ?? (idx.last - idx.change);
      final newChange = double.parse((newLast - prevClose).toStringAsFixed(2));
      final newChangePct = prevClose == 0 ? 0.0 : double.parse(((newChange / prevClose) * 100).toStringAsFixed(2));

      final newSparkline = List<double>.from(idx.sparkline);
      if (newSparkline.isNotEmpty) {
        newSparkline.add(newLast);
        if (newSparkline.length > 20) newSparkline.removeAt(0);
      }

      updatedIndices.add(idx.copyWith(
        last: newLast,
        change: newChange,
        changePct: newChangePct,
        sparkline: newSparkline,
      ));
    }

    _snapshot = MarketSnapshot(
      indices: updatedIndices,
      gainers: current.gainers,
      losers: current.losers,
      isLive: current.isLive,
      source: current.source,
      fetchedAt: DateTime.now(),
    );
    if (!_disposed) notifyListeners();
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    _liveTickerTimer?.cancel();
    _liveTickerTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    stopAutoRefresh();
    super.dispose();
  }

  // ------------------------------------------------------------------ market
  MarketSnapshot? _snapshot;
  bool _marketLoading = false;
  String? _marketError;
  DateTime? _lastMarketRefresh;

  bool _isInitialLoading = true;
  String? _lastErrorNotice;

  bool get isInitialLoading => _isInitialLoading;
  String? get lastErrorNotice => _lastErrorNotice;
  bool get hasDashboardData =>
      indices.isNotEmpty || ipos.isNotEmpty || news.isNotEmpty;

  String? consumeLastErrorNotice() {
    final msg = _lastErrorNotice;
    _lastErrorNotice = null;
    return msg;
  }

  void notifyUserError(String message) {
    _lastErrorNotice = message;
    notifyListeners();
  }

  String _formatUserFriendlyError(Object error, String feature) {
    final s = error.toString().toLowerCase();
    if (s.contains('connection refused') ||
        s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('network is unreachable') ||
        s.contains('clientexception')) {
      return 'Server ya Internet se connect nahi ho pa raha hai. Kripya connection check karein.';
    }
    if (s.contains('timed out') || s.contains('timeout')) {
      return '$feature connect hone me samay lag raha hai. Kripya dobara koshish karein.';
    }
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return '$feature server abhi vyast hai. Kripya kuch der baad refresh karein.';
    }
    return '$feature update nahi ho paya. Kripya internet connection check karein.';
  }

  MarketSnapshot? get snapshot => _snapshot;
  bool get marketLoading => _marketLoading;
  String? get marketError => _marketError;
  List<MarketIndex> get indices => _snapshot?.indices ?? const [];

  Future<void> loadMarket({bool force = false, bool notify = true}) async {
    if (_marketLoading && !force) return;
    _marketLoading = true;
    _marketError = null;
    if (notify) notifyListeners();
    try {
      final snap = await _market.fetchSnapshot();
      if (snap.indices.isNotEmpty || snap.gainers.isNotEmpty) {
        _snapshot = snap;
        _lastMarketRefresh = DateTime.now();
        _recomputeLocalSuggestions();
      }
    } catch (e) {
      _marketError = e.toString();
      _lastErrorNotice = _formatUserFriendlyError(e, 'Share Market data');
    } finally {
      _marketLoading = false;
      if (notify) notifyListeners();
    }
  }

  // --------------------------------------------------------------------- IPO
  IpoFeed? _ipoFeed;
  bool _ipoLoading = false;
  String? _ipoError;
  DateTime? _lastIpoRefresh;
  DateTime? _lastNewsRefresh;

  List<Ipo> get ipos => _ipoFeed?.ipos ?? const [];
  bool get ipoLoading => _ipoLoading;
  bool get ipoIsLive => _ipoFeed?.isLive ?? false;
  DateTime? get ipoFetchedAt => _ipoFeed?.fetchedAt;
  MarketDataSource get ipoSource => _ipoFeed?.source ?? MarketDataSource.unknown;
  String? get ipoError => _ipoError;

  List<Ipo> iposWhere(IpoStatus s) => ipos.where((i) => i.status == s).toList();

  Ipo? ipoById(String id) => ipos.where((i) => i.id == id).firstOrNull;

  Future<void> loadIpos({bool force = false, bool notify = true}) async {
    if (_ipoLoading && !force) return;
    _ipoLoading = true;
    _ipoError = null;
    if (notify) notifyListeners();
    try {
      final feed = await _ipo.fetchIpos();
      if (feed.ipos.isNotEmpty) {
        _ipoFeed = feed;
        _lastIpoRefresh = DateTime.now();
      }
    } catch (e) {
      _ipoError = e.toString();
      _lastErrorNotice = _formatUserFriendlyError(e, 'IPO data');
    } finally {
      _ipoLoading = false;
      if (notify) notifyListeners();
    }
  }

  // -------------------------------------------------------------------- news
  NewsFeedResult? _newsResult;
  bool _newsLoading = false;
  String? _newsError;

  List<NewsArticle> get news => _newsResult?.articles ?? const [];
  bool get newsLoading => _newsLoading;
  bool get newsIsLive => _newsResult?.isLive ?? false;
  String? get newsError => _newsError;

  Future<void> loadNews({bool force = false, bool notify = true}) async {
    if (_newsLoading && !force) return;
    _newsLoading = true;
    _newsError = null;
    if (notify) notifyListeners();
    try {
      final res = await _news.fetchAll();
      if (res.articles.isNotEmpty) {
        _newsResult = res;
        _lastNewsRefresh = DateTime.now();
        _recomputeLocalSuggestions();
      }
      _brief = null;
    } catch (e) {
      _newsError = e.toString();
      _lastErrorNotice = _formatUserFriendlyError(e, 'Market News');
    } finally {
      _newsLoading = false;
      if (notify) notifyListeners();
    }
  }

  // -------------------------------------------------------- global market
  GlobalSnapshot? _globalSnapshot;
  NewsFeedResult? _globalNews;
  bool _globalLoading = false;
  String? _globalError;
  DateTime? _lastGlobalRefresh;

  GlobalSnapshot? get globalSnapshot => _globalSnapshot;
  List<MarketIndex> get globalIndices => _globalSnapshot?.indices ?? const [];
  List<StockQuote> get globalStocks => _globalSnapshot?.stocks ?? const [];
  List<NewsArticle> get globalNews => _globalNews?.articles ?? const [];
  bool get globalNewsIsLive => _globalNews?.isLive ?? false;
  bool get globalLoading => _globalLoading;
  String? get globalError => _globalError;

  Future<void> loadGlobal({bool force = false, bool notify = true}) async {
    if (_globalLoading && !force) return;
    _globalLoading = true;
    _globalError = null;
    if (notify) notifyListeners();
    try {
      final (snap, feed) = await (_global.fetchSnapshot(), _news.fetchGlobal()).wait;
      if (snap.indices.isNotEmpty || snap.stocks.isNotEmpty) {
        _globalSnapshot = snap;
      }
      if (feed.articles.isNotEmpty) {
        _globalNews = feed;
      }
      _lastGlobalRefresh = DateTime.now();
      _recomputeGlobalSuggestions();
    } catch (e) {
      _globalError = e.toString();
      _lastErrorNotice = _formatUserFriendlyError(e, 'Global market data');
    } finally {
      _globalLoading = false;
      if (notify) notifyListeners();
    }
  }

  // -------------------------------------------------------- suggestions
  List<StockSuggestion> _stockSuggestions = const [];
  List<StockSuggestion> _globalSuggestions = const [];
  Sentiment _marketMood = const Sentiment('Neutral', 0);
  Sentiment _globalMood = const Sentiment('Neutral', 0);

  Sentiment get globalMood => _globalMood;
  Sentiment get marketMood => _marketMood;
  List<StockSuggestion> get stockSuggestions => _stockSuggestions;
  List<StockSuggestion> get globalSuggestions => _globalSuggestions;

  void _recomputeLocalSuggestions() {
    _marketMood = AiService.marketMood(news, indices);
    final snap = _snapshot;
    if (snap != null) {
      final universe = <String, StockQuote>{
        for (final q in [...snap.gainers, ...snap.losers]) q.symbol: q,
      };
      _stockSuggestions = AiService.suggestStocks(universe.values.toList(), news, _marketMood);
    }
  }

  void _recomputeGlobalSuggestions() {
    _globalMood = AiService.marketMood(globalNews, globalIndices);
    _globalSuggestions = AiService.suggestStocks(globalStocks, globalNews, _globalMood);
  }

  Future<void> refreshAll() async {
    _marketLoading = true;
    _ipoLoading = true;
    _newsLoading = true;
    _globalLoading = true;
    notifyListeners();

    await Future.wait([
      loadMarket(force: true, notify: false),
      loadIpos(force: true, notify: false),
      loadNews(force: true, notify: false),
      loadGlobal(force: true, notify: false),
    ]);
    _recomputeLocalSuggestions();
    _recomputeGlobalSuggestions();
    _isInitialLoading = false;
    _marketLoading = false;
    _ipoLoading = false;
    _newsLoading = false;
    _globalLoading = false;
    notifyListeners();
  }

  Future<void> refreshAllSilently() async {
    if (_disposed || _isRefreshRunning) {
      if (kDebugMode && _isRefreshRunning) {
        debugPrint('[MarketRefresh] skipped - request already running');
      }
      return;
    }
    _isRefreshRunning = true;
    try {
      if (kDebugMode) debugPrint('[MarketRefresh] tick - started');
      final now = DateTime.now();
      final shouldFetchIpo = _lastIpoRefresh == null ||
          now.difference(_lastIpoRefresh!) >= const Duration(seconds: 45);
      final shouldFetchNews = _lastNewsRefresh == null ||
          now.difference(_lastNewsRefresh!) >= const Duration(seconds: 45);
      final shouldFetchMarket = _lastMarketRefresh == null ||
          now.difference(_lastMarketRefresh!) >= const Duration(seconds: 30);
      final shouldFetchGlobal = _lastGlobalRefresh == null ||
          now.difference(_lastGlobalRefresh!) >= const Duration(seconds: 45);

      final results = await Future.wait([
        shouldFetchMarket ? _market.fetchSnapshot() : Future.value(_snapshot ?? MarketSnapshot(indices: [], gainers: [], losers: [], isLive: false, fetchedAt: now)),
        shouldFetchIpo ? _ipo.fetchIpos() : Future.value(_ipoFeed),
        shouldFetchNews ? _news.fetchAll() : Future.value(_newsResult),
        shouldFetchGlobal ? _global.fetchSnapshot() : Future.value(_globalSnapshot ?? GlobalSnapshot(indices: [], stocks: [], isLive: false, fetchedAt: now)),
      ]);

      if (shouldFetchIpo) _lastIpoRefresh = now;
      if (shouldFetchNews) _lastNewsRefresh = now;
      if (shouldFetchMarket) _lastMarketRefresh = now;
      if (shouldFetchGlobal) _lastGlobalRefresh = now;

      if (_disposed) return;

      final snap = results[0] as MarketSnapshot;
      final ipoFeed = results[1] as IpoFeed?;
      final newsFeed = results[2] as NewsFeedResult?;
      final globalSnap = results[3] as GlobalSnapshot;

      bool changed = false;

      if (snap.indices.isNotEmpty || snap.gainers.isNotEmpty) {
        if (_hasMarketChanged(_snapshot, snap)) {
          _snapshot = snap;
          changed = true;
        }
      }

      if (ipoFeed != null && ipoFeed.ipos.isNotEmpty) {
        if (_hasIposChanged(_ipoFeed, ipoFeed)) {
          _ipoFeed = ipoFeed;
          changed = true;
        }
      }

      if (newsFeed != null && newsFeed.articles.isNotEmpty) {
        if (_hasNewsChanged(_newsResult, newsFeed)) {
          _newsResult = newsFeed;
          changed = true;
        }
      }

      if (globalSnap.indices.isNotEmpty || globalSnap.stocks.isNotEmpty) {
        if (_hasGlobalChanged(_globalSnapshot, globalSnap)) {
          _globalSnapshot = globalSnap;
          changed = true;
        }
      }

      if (changed && !_disposed) {
        _recomputeLocalSuggestions();
        _recomputeGlobalSuggestions();
        notifyListeners();
      }
      if (kDebugMode) debugPrint('[MarketRefresh] completed');
    } catch (_) {
    } finally {
      _isRefreshRunning = false;
    }
  }

  bool _hasMarketChanged(MarketSnapshot? oldS, MarketSnapshot newS) {
    if (oldS == null) return true;
    if (oldS.indices.length != newS.indices.length) return true;
    for (var i = 0; i < oldS.indices.length; i++) {
      if (oldS.indices[i].last != newS.indices[i].last ||
          oldS.indices[i].change != newS.indices[i].change) {
        return true;
      }
    }
    return false;
  }

  bool _hasIposChanged(IpoFeed? oldF, IpoFeed newF) {
    if (oldF == null) return true;
    if (oldF.ipos.length != newF.ipos.length) return true;
    for (var i = 0; i < oldF.ipos.length; i++) {
      if (oldF.ipos[i].totalSubscription != newF.ipos[i].totalSubscription ||
          oldF.ipos[i].gmp != newF.ipos[i].gmp ||
          oldF.ipos[i].status != newF.ipos[i].status) {
        return true;
      }
    }
    return false;
  }

  bool _hasNewsChanged(NewsFeedResult? oldN, NewsFeedResult newN) {
    if (oldN == null) return true;
    if (oldN.articles.length != newN.articles.length) return true;
    if (oldN.articles.firstOrNull?.title != newN.articles.firstOrNull?.title) return true;
    return false;
  }

  bool _hasGlobalChanged(GlobalSnapshot? oldG, GlobalSnapshot newG) {
    if (oldG == null) return true;
    if (oldG.indices.length != newG.indices.length) return true;
    for (var i = 0; i < oldG.indices.length; i++) {
      if (oldG.indices[i].last != newG.indices[i].last) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------- AI brief
  String? _brief;
  bool _briefLoading = false;
  String? get brief => _brief;
  bool get briefLoading => _briefLoading;

  Future<void> loadBrief() async {
    if (_briefLoading) return;
    _briefLoading = true;
    notifyListeners();
    _brief = await ai.marketBrief(indices, news);
    _briefLoading = false;
    notifyListeners();
  }

  // --------------------------------------------------------------- watchlist
  late Set<String> _watchlist;
  bool isWatched(String ipoId) => _watchlist.contains(ipoId);
  Future<void> toggleWatch(String ipoId) async {
    if (!_watchlist.remove(ipoId)) _watchlist.add(ipoId);
    await storage.saveWatchlist(_watchlist);
    notifyListeners();
  }

  // ---------------------------------------------------------------- profiles
  late List<PanProfile> _profiles;
  List<PanProfile> get profiles => List.unmodifiable(_profiles);

  Future<String?> addProfile(String name, String pan,
      {String? applicationNumber, String? dpId}) async {
    final upper = pan.toUpperCase().trim();
    if (!PanProfile.isValidPan(upper)) return 'Invalid PAN format (e.g. ABCDE1234F)';
    if (_profiles.any((p) => p.pan == upper)) return 'This PAN is already added';
    _profiles.add(PanProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      pan: upper,
      applicationNumber: applicationNumber?.trim().isEmpty ?? true ? null : applicationNumber!.trim(),
      dpId: dpId?.trim().isEmpty ?? true ? null : dpId!.trim(),
    ));
    await storage.saveProfiles(_profiles);
    notifyListeners();
    return null;
  }

  Future<void> updateProfile(PanProfile p) async {
    final i = _profiles.indexWhere((e) => e.id == p.id);
    if (i == -1) return;
    _profiles[i] = p;
    await storage.saveProfiles(_profiles);
    notifyListeners();
  }

  Future<void> removeProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    _allotments.removeWhere((_, r) => r.profileId == id);
    await storage.saveProfiles(_profiles);
    await storage.saveAllotments(_allotments.values.toList());
    notifyListeners();
  }

  // -------------------------------------------------------------- allotments
  late Map<String, AllotmentResult> _allotments;
  bool _checking = false;
  bool get checkingAllotment => _checking;

  AllotmentResult? allotmentFor(String profileId, String ipoId) =>
      _allotments['$profileId|$ipoId'];

  List<AllotmentResult> allotmentsForIpo(String ipoId) =>
      _allotments.values.where((r) => r.ipoId == ipoId).toList();

  Future<void> recordAllotment(AllotmentResult r) async {
    _allotments[r.key] = r;
    await storage.saveAllotments(_allotments.values.toList());
    notifyListeners();
  }

  Future<String?> checkAllotmentsFor(Ipo ipo) async {
    if (_profiles.isEmpty) return 'Add at least one PAN first';
    if (_checking) return 'Check already in progress';
    _checking = true;
    notifyListeners();
    try {
      final results = await allotmentService.checkMany(ipo, _profiles);
      for (final r in results) {
        _allotments[r.key] = r;
      }
      await storage.saveAllotments(_allotments.values.toList());
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------- chat
  late List<ChatMessage> _chat;
  bool _chatBusy = false;
  List<ChatMessage> get chat => List.unmodifiable(_chat);
  bool get chatBusy => _chatBusy;

  String _liveContext() {
    final b = StringBuffer();
    if (indices.isNotEmpty) {
      b.writeln('Indices:');
      for (final i in indices) {
        b.writeln('- ${i.name}: ${i.last.toStringAsFixed(2)} (${i.changePct.toStringAsFixed(2)}%)');
      }
    }
    final open = iposWhere(IpoStatus.open);
    if (open.isNotEmpty) {
      b.writeln('Open IPOs:');
      for (final i in open) {
        b.writeln('- ${i.name}: ₹${i.priceMin.toStringAsFixed(0)}-${i.priceMax.toStringAsFixed(0)}, lot ${i.lotSize}, subscribed ${i.totalSubscription.toStringAsFixed(1)}x, GMP ${i.gmp ?? 'n/a'}');
      }
    }
    if (news.isNotEmpty) {
      b.writeln('Headlines:');
      for (final a in news.take(8)) {
        b.writeln('- ${a.title}');
      }
    }
    return b.toString();
  }

  Future<void> sendChat(String text) async {
    if (text.trim().isEmpty || _chatBusy) return;
    _chat.add(ChatMessage(role: 'user', text: text.trim(), at: DateTime.now()));
    _chatBusy = true;
    notifyListeners();
    String reply;
    try {
      reply = await ai.chat(_chat, context: _liveContext());
    } catch (e) {
      reply = 'Sorry, SpotAI could not respond: $e';
    }
    _chat.add(ChatMessage(role: 'assistant', text: reply, at: DateTime.now()));
    _chatBusy = false;
    await storage.saveChat(_chat);
    notifyListeners();
  }

  Future<void> clearChat() async {
    _chat = [];
    await storage.saveChat(_chat);
    notifyListeners();
  }

  // ---------------------------------------------------------------- settings
  late bool _darkMode;
  bool get darkMode => _darkMode;
  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await storage.setDarkMode(v);
    notifyListeners();
  }

  Future<void> setAiConfig({required String provider, required String apiKey}) async {
    ai.provider = provider;
    ai.apiKey = apiKey;
    await storage.setAiProvider(provider);
    await storage.setAiApiKey(apiKey);
    _brief = null;
    notifyListeners();
  }
}
