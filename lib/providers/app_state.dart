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
    _profiles = storage.loadProfiles();
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

  // ------------------------------------------------------------------ market
  MarketSnapshot? _snapshot;
  bool _marketLoading = false;
  String? _marketError;

  MarketSnapshot? get snapshot => _snapshot;
  bool get marketLoading => _marketLoading;
  String? get marketError => _marketError;
  List<MarketIndex> get indices => _snapshot?.indices ?? const [];

  Future<void> loadMarket() async {
    _marketLoading = true;
    _marketError = null;
    notifyListeners();
    try {
      _snapshot = await _market.fetchSnapshot();
    } catch (e) {
      _marketError = e.toString();
    } finally {
      _marketLoading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------- IPO
  IpoFeed? _ipoFeed;
  bool _ipoLoading = false;

  List<Ipo> get ipos => _ipoFeed?.ipos ?? const [];
  bool get ipoLoading => _ipoLoading;
  bool get ipoIsLive => _ipoFeed?.isLive ?? false;

  List<Ipo> iposWhere(IpoStatus s) => ipos.where((i) => i.status == s).toList();

  Ipo? ipoById(String id) => ipos.where((i) => i.id == id).firstOrNull;

  Future<void> loadIpos() async {
    _ipoLoading = true;
    notifyListeners();
    _ipoFeed = await _ipo.fetchIpos();
    _ipoLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------------------- news
  NewsFeedResult? _newsResult;
  bool _newsLoading = false;

  List<NewsArticle> get news => _newsResult?.articles ?? const [];
  bool get newsLoading => _newsLoading;
  bool get newsIsLive => _newsResult?.isLive ?? false;

  Future<void> loadNews() async {
    _newsLoading = true;
    notifyListeners();
    _newsResult = await _news.fetchAll();
    _newsLoading = false;
    _brief = null;
    notifyListeners();
  }

  // -------------------------------------------------------- global market
  GlobalSnapshot? _globalSnapshot;
  NewsFeedResult? _globalNews;
  bool _globalLoading = false;

  GlobalSnapshot? get globalSnapshot => _globalSnapshot;
  List<MarketIndex> get globalIndices => _globalSnapshot?.indices ?? const [];
  List<StockQuote> get globalStocks => _globalSnapshot?.stocks ?? const [];
  List<NewsArticle> get globalNews => _globalNews?.articles ?? const [];
  bool get globalNewsIsLive => _globalNews?.isLive ?? false;
  bool get globalLoading => _globalLoading;

  Future<void> loadGlobal() async {
    _globalLoading = true;
    notifyListeners();
    final (snap, feed) = await (_global.fetchSnapshot(), _news.fetchGlobal()).wait;
    _globalSnapshot = snap;
    _globalNews = feed;
    _globalLoading = false;
    notifyListeners();
  }

  Sentiment get globalMood => AiService.marketMood(globalNews, globalIndices);

  // -------------------------------------------------------- suggestions
  /// Buy / sell / hold ideas for Indian large caps (gainers + losers universe).
  List<StockSuggestion> get stockSuggestions {
    final snap = _snapshot;
    if (snap == null) return const [];
    final universe = <String, StockQuote>{
      for (final q in [...snap.gainers, ...snap.losers]) q.symbol: q,
    };
    return AiService.suggestStocks(universe.values.toList(), news, marketMood);
  }

  List<StockSuggestion> get globalSuggestions =>
      AiService.suggestStocks(globalStocks, globalNews, globalMood);

  Future<void> refreshAll() =>
      Future.wait([loadMarket(), loadIpos(), loadNews(), loadGlobal()]);

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

  Sentiment get marketMood => AiService.marketMood(news, indices);

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
