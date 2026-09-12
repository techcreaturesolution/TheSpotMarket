import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import 'sample_data.dart';

class NewsFeedResult {
  const NewsFeedResult({required this.articles, required this.isLive});
  final List<NewsArticle> articles;
  final bool isLive;
}

/// Aggregates RSS feeds from major Indian financial publishers
/// (Economic Times, Moneycontrol, Livemint, Business Standard).
class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final _rfc822 = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US');

  Future<NewsFeedResult> fetchAll() =>
      fetchFeeds(AppConfig.newsFeeds, fallback: SampleData.news);

  Future<NewsFeedResult> fetchGlobal() =>
      fetchFeeds(AppConfig.globalNewsFeeds, fallback: SampleData.globalNews);

  Future<NewsFeedResult> fetchFeeds(
    List<NewsFeed> feeds, {
    required List<NewsArticle> Function() fallback,
  }) async {
    final results = await Future.wait(
      feeds.map(_fetchFeed),
      eagerError: false,
    );
    final articles = results.expand((e) => e).toList();
    if (articles.isEmpty) {
      return NewsFeedResult(articles: fallback(), isLive: false);
    }
    final seen = <String>{};
    final deduped = articles
        .where((a) => seen.add(a.title.toLowerCase().trim()))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return NewsFeedResult(articles: deduped, isLive: true);
  }

  Future<List<NewsArticle>> _fetchFeed(NewsFeed feed) async {
    try {
      final res = await _client.get(Uri.parse(feed.url), headers: {
        'User-Agent': 'TheSpotMarket/1.0 (+https://thespotmarket.app)',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return const [];
      return parseRss(res.body, feed.name);
    } catch (_) {
      return const [];
    }
  }

  static List<NewsArticle> parseRss(String body, String sourceName) {
    final doc = XmlDocument.parse(body);
    return doc.findAllElements('item').map((item) {
      String text(String tag) =>
          item.getElement(tag)?.innerText.trim() ?? '';
      final title = _stripHtml(text('title'));
      if (title.isEmpty) return null;
      final desc = _stripHtml(text('description'));
      final image = item.getElement('media:content')?.getAttribute('url') ??
          item.getElement('media:thumbnail')?.getAttribute('url') ??
          item.getElement('enclosure')?.getAttribute('url') ??
          _firstImg(text('description'));
      return NewsArticle(
        title: title,
        link: text('link').isNotEmpty ? text('link') : text('guid'),
        source: sourceName.split(' - ').first,
        publishedAt: _parseDate(text('pubDate')),
        description: desc.isEmpty ? null : desc,
        imageUrl: image,
      );
    }).whereType<NewsArticle>().toList();
  }

  static DateTime _parseDate(String raw) {
    if (raw.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(raw);
    } catch (_) {}
    try {
      final cleaned = raw.replaceAll(RegExp(r'\s+(GMT|UTC|IST|[+-]\d{4})$'), '');
      final dt = _rfc822.parseUtc(cleaned);
      final tz = RegExp(r'([+-])(\d{2})(\d{2})$').firstMatch(raw);
      if (tz != null) {
        final sign = tz.group(1) == '+' ? 1 : -1;
        final off = Duration(
            hours: int.parse(tz.group(2)!), minutes: int.parse(tz.group(3)!));
        return dt.subtract(off * sign).toLocal();
      }
      if (raw.endsWith('IST')) {
        return dt.subtract(const Duration(hours: 5, minutes: 30)).toLocal();
      }
      return dt.toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  static String _stripHtml(String s) => s
      .replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), '')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .trim();

  static String? _firstImg(String html) =>
      RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(html)?.group(1);
}
