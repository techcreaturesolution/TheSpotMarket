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
    final seenKeys = <String>{};
    final deduped = <NewsArticle>[];
    for (final a in articles) {
      final key = a.link.trim().isNotEmpty
          ? a.link.trim().toLowerCase()
          : '${a.source.toLowerCase().trim()}|${a.title.toLowerCase().trim()}';
      if (seenKeys.add(key)) {
        deduped.add(a);
      }
    }
    deduped.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
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
    try {
      final doc = XmlDocument.parse(body);
      Iterable<XmlElement> items = doc.findAllElements('item');
      if (items.isEmpty) {
        items = doc.findAllElements('entry');
      }
      return items.map((item) {
        String text(String tag) {
          final el = item.findElements(tag).firstOrNull;
          return el?.innerText.trim() ?? '';
        }

        final title = _stripHtml(text('title'));
        if (title.isEmpty) return null;

        final desc = _stripHtml(text('description').isNotEmpty
            ? text('description')
            : (text('summary').isNotEmpty ? text('summary') : text('content')));

        final linkEl = item.findElements('link').firstOrNull;
        String link = linkEl?.getAttribute('href') ?? linkEl?.innerText.trim() ?? '';
        if (link.isEmpty) {
          link = text('guid').isNotEmpty ? text('guid') : text('id');
        }

        final image = item.findElements('media:content').firstOrNull?.getAttribute('url') ??
            item.findElements('media:thumbnail').firstOrNull?.getAttribute('url') ??
            item.findElements('enclosure').firstOrNull?.getAttribute('url') ??
            _firstImg(text('description')) ??
            _firstImg(text('content'));

        final rawDate = text('pubDate').isNotEmpty
            ? text('pubDate')
            : (text('dc:date').isNotEmpty
                ? text('dc:date')
                : (text('published').isNotEmpty
                    ? text('published')
                    : (text('updated').isNotEmpty ? text('updated') : text('date'))));

        return NewsArticle(
          title: title,
          link: link,
          source: sourceName.split(' - ').first,
          publishedAt: _parseDate(rawDate),
          description: desc.isEmpty ? null : desc,
          imageUrl: image,
        );
      }).whereType<NewsArticle>().toList();
    } catch (_) {
      return const [];
    }
  }

  static DateTime _parseDate(String raw) {
    if (raw.trim().isEmpty) return DateTime.now();
    try {
      final dt = DateTime.tryParse(raw.trim());
      if (dt != null) return dt;
    } catch (_) {}
    try {
      final cleaned = raw.trim().replaceAll(RegExp(r'\s+(GMT|UTC|IST|EST|EDT|PST|PDT|CST|CDT|[+-]\d{4})$'), '');
      final dt = _rfc822.parseUtc(cleaned);
      final tz = RegExp(r'([+-])(\d{2})(\d{2})$').firstMatch(raw);
      if (tz != null) {
        final sign = tz.group(1) == '+' ? 1 : -1;
        final off = Duration(
            hours: int.parse(tz.group(2)!), minutes: int.parse(tz.group(3)!));
        return dt.subtract(off * sign).toLocal();
      }
      if (raw.contains('IST')) {
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
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#8217;', "'")
      .replaceAll('&#8220;', '"')
      .replaceAll('&#8221;', '"')
      .replaceAll('&#8211;', '-')
      .replaceAll('&#8212;', '—')
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '-')
      .trim();

  static String? _firstImg(String html) =>
      RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(html)?.group(1);
}
