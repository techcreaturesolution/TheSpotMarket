import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:thespotmarket/config/app_config.dart';
import 'package:thespotmarket/models/models.dart';
import 'package:thespotmarket/providers/app_state.dart';
import 'package:thespotmarket/services/ai_service.dart';
import 'package:thespotmarket/services/auth_service.dart';
import 'package:thespotmarket/services/global_market_service.dart';
import 'package:thespotmarket/services/market_service.dart';
import 'package:thespotmarket/services/allotment_service.dart';
import 'package:thespotmarket/services/ipo_service.dart';
import 'package:thespotmarket/services/news_service.dart';
import 'package:thespotmarket/services/sample_data.dart';
import 'package:thespotmarket/services/storage_service.dart';

class MockClient extends http.BaseClient {
  MockClient(this._handler);
  final Future<http.Response> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PAN validation', () {
    test('accepts valid PAN', () {
      expect(PanProfile.isValidPan('ABCDE1234F'), isTrue);
      expect(PanProfile.isValidPan('abcde1234f'), isTrue);
    });
    test('rejects invalid PAN', () {
      expect(PanProfile.isValidPan('ABCD1234F'), isFalse);
      expect(PanProfile.isValidPan('ABCDE12345'), isFalse);
      expect(PanProfile.isValidPan(''), isFalse);
    });
  });

  group('IPO', () {
    final ipos = SampleData.ipos();
    test('sample data has every lifecycle stage', () {
      final statuses = ipos.map((i) => i.statusOn(DateTime.now())).toSet();
      expect(statuses, containsAll(IpoStatus.values));
    });
    test('AI score is bounded 0..100 with a verdict', () {
      for (final ipo in ipos) {
        final s = AiService.scoreIpo(ipo);
        expect(s.score, inInclusiveRange(0, 100));
        expect(s.verdict, isNotEmpty);
        expect(s.reasons, isNotEmpty);
      }
    });
  });

  group('Sentiment', () {
    test('classifies bullish and bearish headlines', () {
      expect(AiService.sentimentOf('Sensex surges 800 points, Nifty hits record high').label,
          'Bullish');
      expect(AiService.sentimentOf('Markets crash as FII selloff deepens, Nifty slumps').label,
          'Bearish');
    });
  });

  group('Stock suggestions', () {
    test('produces buy for momentum + good news, sell for weakness + bad news', () {
      const up = StockQuote(symbol: 'INFY', name: 'Infosys', lastPrice: 1800, change: 40, changePct: 2.2, volume: 9000000, sector: 'IT', sparkline: [1700, 1720, 1750, 1780, 1800]);
      const down = StockQuote(symbol: 'HDFCBANK', name: 'HDFC Bank', lastPrice: 1600, change: -30, changePct: -1.9, volume: 9000000, sector: 'Banking', sparkline: [1680, 1660, 1640, 1620, 1600]);
      final news = [
        NewsArticle(title: 'Infosys surges on strong guidance, brokerages upgrade', link: 'x', source: 'ET', publishedAt: DateTime.now()),
        NewsArticle(title: 'HDFC Bank slumps as NPA fears weigh; downgrade by analysts', link: 'y', source: 'ET', publishedAt: DateTime.now()),
      ];
      final ideas = AiService.suggestStocks([up, down], news, const Sentiment('Neutral', 0));
      final bySym = {for (final i in ideas) i.quote.symbol: i};
      expect(bySym['INFY']!.action, TradeAction.buy);
      expect(bySym['INFY']!.target, greaterThan(1800));
      expect(bySym['INFY']!.stopLoss, lessThan(1800));
      expect(bySym['HDFCBANK']!.action, TradeAction.sell);
      expect(bySym['HDFCBANK']!.target, lessThan(1600));
      expect(ideas.first.action, TradeAction.buy);
      for (final i in ideas) {
        expect(i.confidence, inInclusiveRange(35, 92));
        expect(i.reasons, isNotEmpty);
      }
    });

    test('global sample universe yields ideas in every bucket', () {
      final ideas = AiService.suggestStocks(SampleData.globalStocks(), SampleData.globalNews(), const Sentiment('Neutral', 0));
      expect(ideas.length, SampleData.globalStocks().length);
      expect(ideas.any((i) => i.action == TradeAction.buy), isTrue);
      expect(ideas.any((i) => i.action == TradeAction.sell), isTrue);
    });
  });

  group('RSS parsing', () {
    test('parses items, pubDate and source', () {
      const rss = '''<?xml version="1.0"?>
<rss version="2.0"><channel><title>Test</title>
<item><title>Nifty ends higher</title><link>https://x/1</link><description>desc</description><pubDate>Mon, 01 Jan 2024 10:00:00 +0530</pubDate></item>
<item><title></title><link>https://x/2</link></item>
<item><title>IPO opens today</title><link>https://x/3</link><pubDate>Mon, 01 Jan 2024 12:00:00 +0530</pubDate></item>
</channel></rss>''';
      final items = NewsService.parseRss(rss, 'Test - Markets');
      expect(items.length, 2);
      expect(items.first.title, 'Nifty ends higher');
      expect(items.first.description, 'desc');
      expect(items.first.source, 'Test');
      expect(items.first.publishedAt.toUtc(), DateTime.utc(2024, 1, 1, 4, 30));
    });
  });

  group('StorageService & Secure PAN Storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('saves and loads PAN profiles in secure storage', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);
      expect(storage.loadProfiles(), isEmpty);

      const profile = PanProfile(id: '1', name: 'John Doe', pan: 'ABCDE1234F');
      await storage.saveProfiles([profile]);

      expect(storage.loadProfiles().length, 1);
      expect(storage.loadProfiles().first.pan, 'ABCDE1234F');
      expect(storage.loadProfiles().first.name, 'John Doe');
      // Ensure plaintext SharedPreferences key is NOT populated
      expect(prefs.containsKey('pan_profiles'), isFalse);
    });

    test('migrates legacy unencrypted SharedPreferences PAN profiles to secure storage', () async {
      const legacyProfilesJson = '[{"id":"101","name":"Jane Doe","pan":"XYZPD9876Q"}]';
      SharedPreferences.setMockInitialValues({
        'pan_profiles': legacyProfilesJson,
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pan_profiles'), legacyProfilesJson);

      final storage = await StorageService.create(prefs: prefs);

      // Verify profiles loaded correctly
      final loaded = storage.loadProfiles();
      expect(loaded.length, 1);
      expect(loaded.first.id, '101');
      expect(loaded.first.name, 'Jane Doe');
      expect(loaded.first.pan, 'XYZPD9876Q');

      // Verify legacy plaintext key in SharedPreferences was erased
      expect(prefs.containsKey('pan_profiles'), isFalse);
    });
  });

  group('Parser Hardening & Network Reliability', () {
    test('handles malformed or incomplete JSON gracefully in models', () {
      final ipo = Ipo.fromJson(const <String, dynamic>{
        'id': 'ipo_test',
        'name': 'Test IPO',
        'priceMin': null,
        'priceMax': '100', // invalid type
        'openDate': 'invalid-date',
      });
      expect(ipo.id, 'ipo_test');
      expect(ipo.name, 'Test IPO');
      expect(ipo.priceMin, 0.0);

      final idx = MarketIndex.fromJson(const <String, dynamic>{
        'name': 'NIFTY 50',
        'last': null,
        'change': null,
      });
      expect(idx.name, 'NIFTY 50');
      expect(idx.last, 0.0);

      final quote = StockQuote.fromNse(const <String, dynamic>{
        'symbol': 'RELIANCE',
        'lastPrice': null,
        'change': null,
      });
      expect(quote.symbol, 'RELIANCE');
      expect(quote.lastPrice, 0.0);
    });

    test('handles malformed XML in RSS parsing without throwing', () {
      const malformedRss = '<html><body>503 Service Unavailable</body></html>';
      final articles = NewsService.parseRss(malformedRss, 'BadFeed');
      expect(articles, isEmpty);
    });
  });

  group('AuthService & Guest Mode Fallback', () {
    test('instantiates safely when Firebase is unavailable', () {
      final auth = AuthService(isAvailable: false);
      expect(auth.isAvailable, isFalse);
      expect(auth.isSignedIn, isFalse);
      expect(auth.user, isNull);
      expect(auth.displayName, 'Guest');
      expect(auth.otpSent, isFalse);
      expect(auth.busy, isFalse);
    });

    test('maps FirebaseAuthException error codes into friendly user messages', () {
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'invalid-email')),
        'Enter a valid email address.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'wrong-password')),
        'Incorrect email or password.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'user-not-found')),
        'Incorrect email or password.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'invalid-credential')),
        'Incorrect email or password.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'user-disabled')),
        'Incorrect email or password.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'email-already-in-use')),
        'An account already exists for this email.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'weak-password')),
        'Password should be at least 6 characters.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'invalid-phone-number')),
        'Enter a valid mobile number with country code (+91…).',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'invalid-verification-code')),
        'Incorrect OTP. Please try again.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'invalid-verification-id')),
        'Incorrect OTP. Please try again.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'too-many-requests')),
        'Too many attempts. Try again later.',
      );
      expect(
        AuthService.friendly(FirebaseAuthException(code: 'network-request-failed')),
        'Network error. Check your connection.',
      );
      expect(
        AuthService.friendly(StateError('Custom state error')),
        'Custom state error',
      );
    });
  });

  group('GlobalMarketService & Hardened Global Data Flow', () {
    test('fetches fallback snapshot safely when live endpoints fail or backend is unconfigured', () async {
      final service = GlobalMarketService();
      final snapshot = await service.fetchSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot.indices, isNotEmpty);
      expect(snapshot.stocks, isNotEmpty);
      expect(snapshot.fetchedAt, isNotNull);
    });

    test('AppState loadGlobal manages globalLoading and loads snapshot without throwing', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final state = AppState(storage: storage);
      expect(state.globalLoading, isFalse);
      expect(state.globalIndices, isEmpty);

      await state.loadGlobal();

      expect(state.globalLoading, isFalse);
      expect(state.globalIndices, isNotEmpty);
      expect(state.globalStocks, isNotEmpty);
      expect(state.globalMood, isNotNull);
      expect(state.globalSuggestions, isNotEmpty);
    });
  });

  group('Phase 5 — Indian Market & NSE Reliability Hardening', () {
    test('parses formatted numeric strings with commas and handles NaN/Infinity', () {
      final index = MarketIndex.fromNse(const {
        'index': 'NIFTY 50',
        'last': '24,812.35',
        'variation': '142.60',
        'percentChange': '0.58',
        'open': '24,690.10',
        'high': '24,855.00',
        'low': '24,640.20',
        'previousClose': '24,669.75',
      });
      expect(index.name, 'NIFTY 50');
      expect(index.last, 24812.35);
      expect(index.change, 142.60);
      expect(index.changePct, 0.58);
      expect(index.open, 24690.10);

      final quote = StockQuote.fromNse(const {
        'symbol': 'INFY',
        'meta': {'companyName': 'Infosys Limited', 'industry': 'IT Services'},
        'lastPrice': '1,892.40',
        'change': '61.20',
        'pChange': '3.34',
        'totalTradedVolume': '8,120,000',
      });
      expect(quote.symbol, 'INFY');
      expect(quote.name, 'Infosys Limited');
      expect(quote.lastPrice, 1892.40);
      expect(quote.volume, 8120000);
      expect(quote.sector, 'IT Services');
    });

    test('handles null, missing, or unexpected meta field structure in NSE stock quotes', () {
      final quoteWithBoolMeta = StockQuote.fromNse(const {
        'symbol': 'TCS',
        'meta': true,
        'lastPrice': 4200.0,
        'change': 50.0,
        'pChange': 1.2,
      });
      expect(quoteWithBoolMeta.symbol, 'TCS');
      expect(quoteWithBoolMeta.name, 'TCS');
      expect(quoteWithBoolMeta.sector, isNull);

      final quoteWithNulls = StockQuote.fromNse(const {
        'symbol': null,
        'meta': null,
        'lastPrice': null,
        'change': null,
        'pChange': null,
        'totalTradedVolume': null,
      });
      expect(quoteWithNulls.symbol, '');
      expect(quoteWithNulls.name, '');
      expect(quoteWithNulls.lastPrice, 0.0);
      expect(quoteWithNulls.volume, isNull);
    });

    test('falls back to SampleData on NSE 403 Akamai block', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://www.nseindia.com') {
          return http.Response('Forbidden', 403);
        }
        return http.Response('Not Found', 404);
      });

      final marketService = MarketService(client: mockClient);
      final snapshot = await marketService.fetchSnapshot();

      expect(snapshot.isLive, isFalse);
      expect(snapshot.indices, isNotEmpty);
      expect(snapshot.gainers, isNotEmpty);
      expect(snapshot.losers, isNotEmpty);
    });

    test('falls back to SampleData on malformed JSON response', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://www.nseindia.com') {
          return http.Response('', 200, headers: {'set-cookie': 'nsesession=123; path=/'});
        }
        return http.Response('{"data": "Not a list"}', 200);
      });

      final marketService = MarketService(client: mockClient);
      final snapshot = await marketService.fetchSnapshot();

      expect(snapshot.isLive, isFalse);
      expect(snapshot.indices, isNotEmpty);
    });

    test('AppState loadMarket maintains state lifecycle and preserves snapshot on exception', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final state = AppState(storage: storage);
      expect(state.marketLoading, isFalse);
      expect(state.snapshot, isNull);

      await state.loadMarket();

      expect(state.marketLoading, isFalse);
      expect(state.snapshot, isNotNull);

      await state.loadMarket(force: true);
      expect(state.marketLoading, isFalse);
      expect(state.snapshot, isNotNull);
    });
  });

  group('Phase 6 — IPO, Allotment & Registrar Data Reliability Hardening', () {
    test('IpoService parses valid JSON array and deduplicates by ID/symbol', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''[
          {
            "id": "ipo_1",
            "name": "Alpha Tech IPO",
            "symbol": "ALPHA",
            "priceMin": "100",
            "priceMax": "120",
            "lotSize": "100",
            "issueSizeCr": "500",
            "openDate": "2026-09-01T00:00:00.000Z",
            "closeDate": "2026-09-05T00:00:00.000Z",
            "allotmentDate": "2026-09-08T00:00:00.000Z",
            "listingDate": "2026-09-12T00:00:00.000Z",
            "gmp": "25",
            "registrar": "Link Intime",
            "status": "closed"
          },
          {
            "id": "ipo_1",
            "name": "Alpha Tech IPO Duplicate",
            "symbol": "ALPHA",
            "priceMin": 100,
            "priceMax": 120
          },
          {
            "id": "ipo_2",
            "name": "Beta Tech IPO",
            "symbol": "BETA",
            "priceMin": "50.5",
            "priceMax": "55.0",
            "lotSize": "200"
          }
        ]''', 200);
      });

      final ipoService = IpoService(client: mockClient);
      final ipos = await ipoService.fetchIpos();

      expect(ipos.length, 2);
      expect(ipos.any((i) => i.id == 'ipo_1' && i.symbol == 'ALPHA'), isTrue);
      expect(ipos.any((i) => i.id == 'ipo_2' && i.symbol == 'BETA'), isTrue);
    });

    test('IpoService handles wrapped JSON map format { "ipos": [...] } safely', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''{
          "ipos": [
            {
              "id": "ipo_3",
              "name": "Gamma Corp IPO",
              "symbol": "GAMMA",
              "priceMin": 200,
              "priceMax": 210,
              "lotSize": 70
            }
          ]
        }''', 200);
      });

      final ipoService = IpoService(client: mockClient);
      final ipos = await ipoService.fetchIpos();

      expect(ipos.length, 1);
      expect(ipos.first.name, 'Gamma Corp IPO');
      expect(ipos.first.lotSize, 70);
    });

    test('IpoService throws and does not fall back to SampleData on network 500 error in live mode', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final ipoService = IpoService(client: mockClient);
      expect(() => ipoService.fetchIpos(), throwsA(isA<Exception>()));
    });

    test('IpoService handles empty IPO API response preserving empty list without fake sample fallback', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final ipoService = IpoService(client: mockClient);
      final feed = await ipoService.fetchIpos();

      expect(feed.ipos, isEmpty);
      expect(feed.isLive, isTrue);
    });

    test('IpoService returns sample fallback only when explicitly requested via allowSampleFallback: true', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final ipoService = IpoService(client: mockClient);
      final feed = await ipoService.fetchIpos(allowSampleFallback: true);

      expect(feed.ipos, isNotEmpty);
      expect(feed.isLive, isFalse);
      expect(feed.source, MarketDataSource.sampleFallback);
      expect(feed.any((i) => i.id == 'sample-open-1'), isTrue);
    });

    test('AllotmentService.checkMany returns AllotmentOutcome.unknown safely on network error', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network disconnected');
      });

      final ipo = SampleData.ipos().first;
      const profile = PanProfile(id: 'p1', name: 'User 1', pan: 'ABCDE1234F');

      final service = AllotmentService(client: mockClient);
      final results = await service.checkMany(ipo, [profile]);

      expect(results.length, 1);
      expect(results.first.profileId, 'p1');
      expect(results.first.outcome, AllotmentOutcome.unknown);
      expect(results.first.note, isNotNull);
    });

    test('AppState loadIpos maintains loading state lifecycle and preserves IPOs', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            "id": "live_ipo_1",
            "name": "Live Real Energy Ltd",
            "symbol": "REALENG",
            "priceMin": 100,
            "priceMax": 105,
            "lotSize": 100,
            "status": "OPEN"
          }
        ]), 200);
      });

      final state = AppState(storage: storage, ipo: IpoService(client: mockClient));
      expect(state.ipoLoading, isFalse);

      await state.loadIpos();

      expect(state.ipoLoading, isFalse);
      expect(state.ipos, isNotEmpty);
      expect(state.ipos.first.symbol, 'REALENG');
      expect(state.ipoError, isNull);
    });

    test('AppState checkAllotmentsFor guards against duplicate parallel calls', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final state = AppState(storage: storage);
      await state.addProfile('Test User', 'ABCDE1234F');
      final ipo = SampleData.ipos().first;

      expect(state.checkingAllotment, isFalse);
      final future1 = state.checkAllotmentsFor(ipo);
      expect(state.checkingAllotment, isTrue);

      // Re-entrant call while running
      final future2 = state.checkAllotmentsFor(ipo);
      expect(await future2, contains('Check already in progress')); // second call exits immediately

      await future1;
      expect(state.checkingAllotment, isFalse);
    });
  });

  group('Phase 7 — News & Content Data Reliability & Performance Hardening', () {
    test('valid RSS XML parses items, titles, links, descriptions and HTML entities successfully', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Markets News</title>
    <item>
      <title>Sensex &amp; Nifty hit record highs &#8217;Today&#8217;</title>
      <link>https://example.com/news/1</link>
      <description>&lt;p&gt;Market rally &amp;mdash; strong earnings report.&lt;/p&gt;</description>
      <pubDate>Fri, 18 Sep 2026 10:00:00 +0530</pubDate>
    </item>
  </channel>
</rss>''';

      final articles = NewsService.parseRss(xml, 'Economic Times - Markets');
      expect(articles.length, 1);
      expect(articles.first.title, "Sensex & Nifty hit record highs ’Today’");
      expect(articles.first.description, 'Market rally — strong earnings report.');
      expect(articles.first.source, 'Economic Times');
      expect(articles.first.link, 'https://example.com/news/1');
    });

    test('Atom XML format with entry elements parses successfully', () {
      const atomXml = '''<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Global Market Feed</title>
  <entry>
    <title>Federal Reserve holds interest rates steady</title>
    <link href="https://example.com/global/100" />
    <summary>US markets react to inflation target announcement.</summary>
    <published>2026-09-18T08:00:00Z</published>
  </entry>
</feed>''';

      final articles = NewsService.parseRss(atomXml, 'CNBC - World Markets');
      expect(articles.length, 1);
      expect(articles.first.title, 'Federal Reserve holds interest rates steady');
      expect(articles.first.link, 'https://example.com/global/100');
      expect(articles.first.source, 'CNBC');
      expect(articles.first.description, 'US markets react to inflation target announcement.');
    });

    test('malformed XML does not crash parseRss and returns empty list', () {
      const badXml = '<html><body>503 Service Unavailable / Cloudflare HTML</body></html>';
      final articles = NewsService.parseRss(badXml, 'Corrupted Feed');
      expect(articles, isEmpty);
    });

    test('missing title or link or malformed date string is handled safely', () {
      const xmlWithMissingFields = '''<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item>
      <description>No title here</description>
    </item>
    <item>
      <title>Valid Title with Invalid Date</title>
      <link>https://example.com/2</link>
      <pubDate>invalid-date-string</pubDate>
    </item>
  </channel>
</rss>''';

      final articles = NewsService.parseRss(xmlWithMissingFields, 'Test Feed');
      expect(articles.length, 1);
      expect(articles.first.title, 'Valid Title with Invalid Date');
      expect(articles.first.publishedAt, isNotNull);
    });

    test('one failed feed does not break overall fetchFeeds operation', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('broken')) {
          return http.Response('Forbidden', 403);
        }
        return http.Response('''<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item>
      <title>Healthy Feed Article</title>
      <link>https://example.com/healthy/1</link>
      <pubDate>Fri, 18 Sep 2026 12:00:00 +0530</pubDate>
    </item>
  </channel>
</rss>''', 200);
      });

      final newsService = NewsService(client: mockClient);
      const feeds = [
        NewsFeed('Healthy Publisher', 'https://example.com/healthy.xml'),
        NewsFeed('Broken Publisher', 'https://example.com/broken.xml'),
      ];

      final result = await newsService.fetchFeeds(feeds, fallback: SampleData.news);
      expect(result.isLive, isTrue);
      expect(result.articles.length, 1);
      expect(result.articles.first.title, 'Healthy Feed Article');
    });

    test('duplicate articles with identical canonical links or title+source are removed', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item>
      <title>Nifty hits 25,000 landmark</title>
      <link>https://example.com/nifty-25k</link>
      <pubDate>Fri, 18 Sep 2026 10:00:00 +0530</pubDate>
    </item>
    <item>
      <title>Nifty hits 25,000 landmark</title>
      <link>https://example.com/nifty-25k</link>
      <pubDate>Fri, 18 Sep 2026 10:05:00 +0530</pubDate>
    </item>
  </channel>
</rss>''', 200);
      });

      final newsService = NewsService(client: mockClient);
      final result = await newsService.fetchFeeds(
        const [NewsFeed('Publisher 1', 'https://example.com/feed.xml')],
        fallback: SampleData.news,
      );

      expect(result.isLive, isTrue);
      expect(result.articles.length, 1);
    });

    test('all-feed failure falls back to SampleData with isLive: false', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final newsService = NewsService(client: mockClient);
      final result = await newsService.fetchFeeds(
        const [NewsFeed('Failing Feed', 'https://example.com/500.xml')],
        fallback: SampleData.news,
      );

      expect(result.isLive, isFalse);
      expect(result.articles, isNotEmpty);
    });

    test('AppState loadNews maintains loading state lifecycle and preserves previous news on error', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final state = AppState(storage: storage);
      expect(state.newsLoading, isFalse);

      await state.loadNews();

      expect(state.newsLoading, isFalse);
      expect(state.news, isNotEmpty);
      expect(state.newsError, isNull);
    });

    test('AppState loadNews guards against duplicate parallel calls', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final state = AppState(storage: storage);

      expect(state.newsLoading, isFalse);
      final future1 = state.loadNews();
      expect(state.newsLoading, isTrue);

      final future2 = state.loadNews(); // Re-entrant call while running
      await future2;

      await future1;
      expect(state.newsLoading, isFalse);
    });
  });

  group('Phase 8 — Progressive Loading & Fake IPO Elimination Hardening', () {
    test('AppState progressive loading updates market state and clears isInitialLoading before slow news completes', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final mockMarketClient = MockClient((request) async {
        return http.Response(jsonEncode({
          "indices": [
            {
              "symbol": "NIFTY 50",
              "name": "NIFTY 50",
              "last": 24500.0,
              "change": 120.0,
              "changePct": 0.49
            }
          ],
          "gainers": [],
          "losers": [],
          "isLive": true
        }), 200);
      });

      final slowNewsCompleter = Completer<http.Response>();
      final mockNewsClient = MockClient((request) => slowNewsCompleter.future);

      final state = AppState(
        storage: storage,
        market: MarketService(client: mockMarketClient),
        news: NewsService(client: mockNewsClient),
      );

      expect(state.isInitialLoading, isTrue);
      expect(state.indices, isEmpty);

      // Trigger refreshAll
      final refreshFuture = state.refreshAll();

      // Yield event loop so market fetch completes while news is still pending
      await Future.delayed(const Duration(milliseconds: 50));

      // Market data arrived and updated state progressively
      expect(state.indices, isNotEmpty);
      expect(state.indices.first.name, 'NIFTY 50');
      expect(state.isInitialLoading, isFalse); // Cleared because primary data arrived!
      expect(state.marketLoading, isFalse);
      expect(state.newsLoading, isTrue); // News is still running independently

      // Now complete the slow news request
      slowNewsCompleter.complete(http.Response('Server Error', 500));
      await refreshFuture;

      expect(state.newsLoading, isFalse);
      expect(state.indices, isNotEmpty); // Market data was never blocked or cleared by slow news
    });

    test('AppState news failure does not hide valid market and IPO data', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      final mockMarketClient = MockClient((request) async {
        return http.Response(jsonEncode({
          "indices": [
            {
              "symbol": "NIFTY 50",
              "name": "NIFTY 50",
              "last": 25000.0,
              "change": 50.0,
              "changePct": 0.2
            }
          ],
          "gainers": [],
          "losers": []
        }), 200);
      });

      final mockIpoClient = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            "id": "ipo_alpha",
            "name": "Alpha Corp",
            "symbol": "ALPHA",
            "status": "OPEN",
            "priceMin": 100,
            "priceMax": 105,
            "lotSize": 100
          }
        ]), 200);
      });

      final mockNewsClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      final state = AppState(
        storage: storage,
        market: MarketService(client: mockMarketClient),
        ipo: IpoService(client: mockIpoClient),
        news: NewsService(client: mockNewsClient),
      );

      await state.refreshAll();

      // Market and IPO succeeded despite news failing
      expect(state.indices, isNotEmpty);
      expect(state.ipos, isNotEmpty);
      expect(state.ipos.first.symbol, 'ALPHA');
      expect(state.hasDashboardData, isTrue);
      expect(state.isInitialLoading, isFalse);
    });

    test('AppState loadIpos preserves previous live IPOs when a subsequent refresh fails', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await StorageService.create(prefs: prefs);

      bool shouldFail = false;
      final mockClient = MockClient((request) async {
        if (shouldFail) {
          return http.Response('Service Unavailable', 503);
        }
        return http.Response(jsonEncode([
          {
            "id": "ipo_preserved",
            "name": "Preserved Technologies Ltd",
            "symbol": "PRESERV",
            "status": "OPEN",
            "priceMin": 200,
            "priceMax": 210,
            "lotSize": 50
          }
        ]), 200);
      });

      final state = AppState(storage: storage, ipo: IpoService(client: mockClient));

      // First fetch succeeds
      await state.loadIpos();
      expect(state.ipos.length, 1);
      expect(state.ipos.first.symbol, 'PRESERV');

      // Second fetch fails
      shouldFail = true;
      await state.loadIpos(force: true);

      // Previous valid real IPOs are preserved, not wiped out or replaced with sample data
      expect(state.ipos.length, 1);
      expect(state.ipos.first.symbol, 'PRESERV');
      expect(state.ipoError, isNotNull);
    });

    test('Bharat Renewables Ltd and Zenith Fintech Services do not appear in live mode on API failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('500 Internal Server Error', 500);
      });

      final ipoService = IpoService(client: mockClient);

      // Calling fetchIpos() without allowSampleFallback throws, never returns fake companies
      expect(
        () => ipoService.fetchIpos(),
        throwsA(isA<Exception>()),
      );
    });
  });
}



