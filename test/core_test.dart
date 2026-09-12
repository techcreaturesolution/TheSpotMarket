import 'package:flutter_test/flutter_test.dart';
import 'package:thespotmarket/models/models.dart';
import 'package:thespotmarket/services/ai_service.dart';
import 'package:thespotmarket/services/news_service.dart';
import 'package:thespotmarket/services/sample_data.dart';

void main() {
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
}
