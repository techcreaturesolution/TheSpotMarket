import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';

class IpoScore {
  const IpoScore({
    required this.score,
    required this.verdict,
    required this.reasons,
  });

  /// 0–100
  final int score;
  final String verdict;
  final List<String> reasons;
}

class Sentiment {
  const Sentiment(this.label, this.score);
  final String label; // Bullish / Bearish / Neutral
  final double score; // -1 .. 1
}

/// AI layer. Uses Gemini or OpenAI when an API key is available and falls back
/// to on-device heuristics (rule-based IPO scoring, keyword sentiment) so the
/// "AI" tabs always show something useful.
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String provider = AppConfig.aiProvider;
  String apiKey = AppConfig.aiApiKey;

  bool get isConfigured => apiKey.isNotEmpty;

  static const systemPrompt = '''
You are SpotAI, the in-app analyst for TheSpotMarket, an Indian stock market app.
You explain IPOs, NSE/BSE stocks, indices and market news in simple language for
retail investors. Always be factual, mention risks, and end with the disclaimer
"Not SEBI-registered investment advice." Keep answers under 200 words unless
asked for detail. Use INR (₹) and Indian market terminology (lot size, GMP, QIB,
NII, retail quota, listing gains).''';

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------
  Future<String> chat(List<ChatMessage> history, {String? context}) async {
    if (!isConfigured) return _offlineReply(history.last.text);
    final sys = context == null ? systemPrompt : '$systemPrompt\n\nLive context:\n$context';
    return provider == 'openai'
        ? _openAi(sys, history)
        : _gemini(sys, history);
  }

  Future<String> _gemini(String system, List<ChatMessage> history) async {
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${AppConfig.geminiModel}:generateContent?key=$apiKey');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {'parts': [{'text': system}]},
              'contents': history
                  .map((m) => {
                        'role': m.isUser ? 'user' : 'model',
                        'parts': [{'text': m.text}],
                      })
                  .toList(),
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 600},
            }))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Gemini error ${res.statusCode}: ${res.body}');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final parts = ((j['candidates'] as List).first['content']['parts'] as List);
    return parts.map((p) => p['text'] as String? ?? '').join().trim();
  }

  Future<String> _openAi(String system, List<ChatMessage> history) async {
    final res = await _client
        .post(Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': AppConfig.openAiModel,
              'temperature': 0.4,
              'max_tokens': 600,
              'messages': [
                {'role': 'system', 'content': system},
                ...history.map((m) => {
                      'role': m.isUser ? 'user' : 'assistant',
                      'content': m.text,
                    }),
              ],
            }))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('OpenAI error ${res.statusCode}: ${res.body}');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return ((j['choices'] as List).first['message']['content'] as String).trim();
  }

  String _offlineReply(String question) {
    final q = question.toLowerCase();
    if (q.contains('gmp')) {
      return 'GMP (Grey Market Premium) is the unofficial price investors are willing to pay over the IPO issue price before listing. A high GMP hints at strong listing demand but it is unregulated and can change quickly.\n\nAdd an AI API key in Settings for live, personalised answers.\n\nNot SEBI-registered investment advice.';
    }
    if (q.contains('allot')) {
      return 'IPO allotment for oversubscribed retail quotas is done by computerised lottery, so applying with multiple PANs (family members) at the cut-off price improves your household odds. Check status on the registrar site after the allotment date — use the Allotment tab here.\n\nNot SEBI-registered investment advice.';
    }
    if (q.contains('lot')) {
      return 'A lot is the minimum number of shares you can apply for in an IPO. Retail investors can apply for up to ₹2 lakh worth of lots; bidding at the cut-off price maximises your chance of allotment.\n\nNot SEBI-registered investment advice.';
    }
    return 'SpotAI is running in offline mode. Add a Gemini or OpenAI API key in Settings to chat about IPOs, NSE/BSE stocks and market news with live context.\n\nMeanwhile, the IPO Score and news sentiment shown across the app are computed on-device.\n\nNot SEBI-registered investment advice.';
  }

  // ---------------------------------------------------------------------------
  // Heuristic analytics (always available)
  // ---------------------------------------------------------------------------
  static IpoScore scoreIpo(Ipo ipo) {
    var score = 50.0;
    final reasons = <String>[];

    final sub = ipo.totalSubscription;
    if (sub > 0) {
      if (sub >= 50) {
        score += 20;
        reasons.add('Heavily oversubscribed (${sub.toStringAsFixed(1)}x)');
      } else if (sub >= 10) {
        score += 12;
        reasons.add('Strong subscription (${sub.toStringAsFixed(1)}x)');
      } else if (sub >= 2) {
        score += 5;
        reasons.add('Decent subscription (${sub.toStringAsFixed(1)}x)');
      } else {
        score -= 10;
        reasons.add('Weak subscription so far (${sub.toStringAsFixed(1)}x)');
      }
    }

    final qib = ipo.subscriptionQib;
    if (qib != null) {
      if (qib >= 20) {
        score += 10;
        reasons.add('Institutional (QIB) demand is very strong');
      } else if (qib < 1) {
        score -= 10;
        reasons.add('Institutions have not filled their quota');
      }
    }

    final gain = ipo.expectedListingGainPct;
    if (gain != null) {
      if (gain >= 30) {
        score += 15;
        reasons.add('GMP implies ~${gain.toStringAsFixed(0)}% listing gain');
      } else if (gain >= 10) {
        score += 8;
        reasons.add('Positive GMP (~${gain.toStringAsFixed(0)}%)');
      } else if (gain < 0) {
        score -= 15;
        reasons.add('GMP is negative – listing may be at a discount');
      } else {
        reasons.add('GMP is flat');
      }
    }

    if (ipo.isSme) {
      score -= 8;
      reasons.add('SME issue: lower liquidity, higher risk');
    }
    if (ipo.issueSizeCr >= 2000) {
      score += 3;
      reasons.add('Large issue size improves post-listing liquidity');
    }
    if (ipo.minInvestment > 15000) {
      reasons.add('Min. investment ₹${ipo.minInvestment.toStringAsFixed(0)} per lot');
    }

    final clamped = score.clamp(0, 100).round();
    final verdict = clamped >= 75
        ? 'Strong Apply'
        : clamped >= 60
            ? 'Apply for listing gains'
            : clamped >= 45
                ? 'Neutral / Long-term only'
                : 'Avoid';
    return IpoScore(score: clamped, verdict: verdict, reasons: reasons);
  }

  static const _bullish = [
    'rally', 'surge', 'jump', 'gain', 'record high', 'buy', 'upgrade',
    'strong', 'beat', 'profit', 'growth', 'oversubscribed', 'premium',
    'inflow', 'bullish', 'soar', 'rebound', 'higher', 'boost',
  ];
  static const _bearish = [
    'fall', 'plunge', 'crash', 'drop', 'loss', 'sell', 'downgrade', 'weak',
    'miss', 'decline', 'slump', 'outflow', 'bearish', 'lower', 'fear',
    'cut', 'default', 'fraud', 'probe', 'slide', 'tumble',
  ];

  static Sentiment sentimentOf(String text) {
    final t = text.toLowerCase();
    var s = 0;
    for (final w in _bullish) {
      if (t.contains(w)) s++;
    }
    for (final w in _bearish) {
      if (t.contains(w)) s--;
    }
    final norm = (s / 3).clamp(-1.0, 1.0);
    return Sentiment(
      norm > 0.2 ? 'Bullish' : norm < -0.2 ? 'Bearish' : 'Neutral',
      norm,
    );
  }

  static Sentiment marketMood(List<NewsArticle> news, List<MarketIndex> idx) {
    var total = 0.0;
    var n = 0;
    for (final a in news.take(30)) {
      total += sentimentOf('${a.title} ${a.description ?? ''}').score;
      n++;
    }
    for (final i in idx) {
      total += (i.changePct / 1.5).clamp(-1.0, 1.0);
      n++;
    }
    if (n == 0) return const Sentiment('Neutral', 0);
    final avg = total / n;
    return Sentiment(
        avg > 0.15 ? 'Bullish' : avg < -0.15 ? 'Bearish' : 'Neutral', avg);
  }

  /// Rule-based buy / sell / hold ideas from price momentum, news mentions and
  /// overall market mood. Purely heuristic; the UI labels it as such.
  static List<StockSuggestion> suggestStocks(
    List<StockQuote> universe,
    List<NewsArticle> news,
    Sentiment mood,
  ) {
    final out = <StockSuggestion>[];
    for (final q in universe) {
      final reasons = <String>[];
      var score = 0.0;

      // Momentum: moderate moves are tradeable, extreme moves look exhausted.
      final pct = q.changePct;
      if (pct >= 0.8 && pct <= 4.5) {
        score += 1.2;
        reasons.add('Positive momentum (+${pct.toStringAsFixed(2)}% today)');
      } else if (pct > 4.5) {
        score -= 0.6;
        reasons.add('Sharp ${pct.toStringAsFixed(1)}% jump – risk of profit booking');
      } else if (pct <= -0.8 && pct >= -4.5) {
        score -= 1.2;
        reasons.add('Negative momentum (${pct.toStringAsFixed(2)}% today)');
      } else if (pct < -4.5) {
        score += 0.4;
        reasons.add('Oversold after ${pct.toStringAsFixed(1)}% fall – watch for bounce');
      }

      // Sparkline trend, when available.
      if (q.sparkline.length >= 4) {
        final first = q.sparkline.first;
        final last = q.sparkline.last;
        final trend = first == 0 ? 0 : (last - first) / first * 100;
        if (trend > 1) {
          score += 0.6;
          reasons.add('Uptrend over recent sessions');
        } else if (trend < -1) {
          score -= 0.6;
          reasons.add('Downtrend over recent sessions');
        }
      }

      // News mentioning the company / sector.
      final keys = <String>{
        q.symbol.toLowerCase(),
        q.name.toLowerCase().split(' ').first,
        if (q.sector != null) q.sector!.toLowerCase(),
      }.where((k) => k.length > 2);
      var newsScore = 0.0;
      var hits = 0;
      for (final a in news) {
        final txt = '${a.title} ${a.description ?? ''}'.toLowerCase();
        if (keys.any(txt.contains)) {
          newsScore += sentimentOf(txt).score;
          hits++;
        }
      }
      if (hits > 0) {
        final avg = newsScore / hits;
        score += avg * 1.5;
        reasons.add(avg > 0.1
            ? 'Positive news flow ($hits headline${hits > 1 ? 's' : ''})'
            : avg < -0.1
                ? 'Negative news flow ($hits headline${hits > 1 ? 's' : ''})'
                : 'Neutral news coverage');
      }

      // Broad market mood.
      score += mood.score * 0.8;
      if (mood.score > 0.15) {
        reasons.add('Supportive ${mood.label.toLowerCase()} market');
      } else if (mood.score < -0.15) {
        reasons.add('Weak ${mood.label.toLowerCase()} market');
      }

      if (q.volume != null && q.volume! > 5000000) {
        reasons.add('High traded volume confirms interest');
        score += score >= 0 ? 0.3 : -0.3;
      }

      final action = score >= 1.0
          ? TradeAction.buy
          : score <= -1.0
              ? TradeAction.sell
              : TradeAction.hold;
      final confidence = (50 + score.abs() * 15).clamp(35, 92).round();
      final swing = (q.lastPrice * (0.03 + pct.abs().clamp(0, 5) / 100));
      final target = action == TradeAction.sell ? q.lastPrice - swing : q.lastPrice + swing;
      final stop = action == TradeAction.sell ? q.lastPrice + swing / 2 : q.lastPrice - swing / 2;

      out.add(StockSuggestion(
        quote: q,
        action: action,
        confidence: confidence,
        reasons: reasons.isEmpty ? ['No strong signal – wait for confirmation'] : reasons,
        target: double.parse(target.toStringAsFixed(2)),
        stopLoss: double.parse(stop.toStringAsFixed(2)),
      ));
    }
    out.sort((a, b) {
      final order = {TradeAction.buy: 0, TradeAction.sell: 1, TradeAction.hold: 2};
      final c = order[a.action]!.compareTo(order[b.action]!);
      return c != 0 ? c : b.confidence.compareTo(a.confidence);
    });
    return out;
  }

  /// One-paragraph market brief built from live data (LLM if available).
  Future<String> marketBrief(
      List<MarketIndex> idx, List<NewsArticle> news) async {
    final mood = marketMood(news, idx);
    final nifty = idx.where((i) => i.name.contains('NIFTY 50')).firstOrNull;
    final sensex = idx.where((i) => i.name.contains('SENSEX')).firstOrNull;
    final ctx = StringBuffer()
      ..writeln('Indices:')
      ..writeAll(idx.map((i) =>
          '- ${i.name}: ${i.last.toStringAsFixed(2)} (${i.changePct >= 0 ? '+' : ''}${i.changePct.toStringAsFixed(2)}%)\n'))
      ..writeln('Top headlines:')
      ..writeAll(news.take(8).map((a) => '- ${a.title}\n'));

    if (isConfigured) {
      try {
        return await chat(
          [
            ChatMessage(
              role: 'user',
              text:
                  'Give a crisp 4-sentence market brief for Indian retail investors based on the live context. Mention overall mood, key movers and one thing to watch.',
              at: DateTime.now(),
            )
          ],
          context: ctx.toString(),
        );
      } catch (_) {}
    }

    final parts = <String>[
      'Market mood is ${mood.label.toLowerCase()} based on index moves and headline sentiment.',
    ];
    if (nifty != null) {
      parts.add(
          'Nifty 50 is ${nifty.isUp ? 'up' : 'down'} ${nifty.changePct.abs().toStringAsFixed(2)}% at ${nifty.last.toStringAsFixed(0)}.');
    }
    if (sensex != null) {
      parts.add(
          'Sensex is ${sensex.isUp ? 'up' : 'down'} ${sensex.changePct.abs().toStringAsFixed(2)}% at ${sensex.last.toStringAsFixed(0)}.');
    }
    final sorted = [...idx]..sort((a, b) => b.changePct.abs().compareTo(a.changePct.abs()));
    if (sorted.isNotEmpty && !sorted.first.name.contains('VIX')) {
      parts.add('${sorted.first.name} is the biggest mover today.');
    }
    return parts.join(' ');
  }
}
