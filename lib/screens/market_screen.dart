import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'suggestions_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use narrow selectors: only rebuild on snapshot/error/loading changes.
    final hasSnap = context.select<AppState, bool>((s) => s.snapshot != null);
    final isLive = context.select<AppState, bool>((s) => s.snapshot?.isLive ?? false);
    final marketLoading = context.select<AppState, bool>((s) => s.marketLoading);
    final isInitialLoading = context.select<AppState, bool>((s) => s.isInitialLoading);
    final marketError = context.select<AppState, String?>((s) => s.marketError);
    final loadMarket = context.read<AppState>().loadMarket;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Share Market'),
          const SizedBox(width: 8),
          if (hasSnap) LiveBadge(live: isLive),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => loadMarket(force: true)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => loadMarket(force: true),
        child: !hasSnap
            ? ((marketLoading || isInitialLoading)
                ? ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: ShimmerBox(width: 150, height: 18, borderRadius: 4),
                      ),
                      StockTileSkeleton(),
                      StockTileSkeleton(),
                      StockTileSkeleton(),
                      StockTileSkeleton(),
                      StockTileSkeleton(),
                    ],
                  )
                : ListView(children: [
                    const SizedBox(height: 160),
                    Center(
                      child: EmptyState(
                        icon: Icons.cloud_off,
                        title: 'Could not load market data',
                        subtitle: marketError,
                        action: FilledButton(onPressed: loadMarket, child: const Text('Retry')),
                      ),
                    ),
                  ]))
            : const _MarketBody(),
      ),
    );
  }
}

class _MarketBody extends StatelessWidget {
  const _MarketBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: const [
        _MarketHeaderSection(),
        SectionHeader('NSE & BSE Indices'),
        _MarketIndicesSection(),
        _MarketSuggestionsSection(),
        SectionHeader('NSE Top Gainers'),
        _MarketGainersSection(),
        NativeAdCard(),
        SectionHeader('NSE Top Losers'),
        _MarketLosersSection(),
        SizedBox(height: 12),
        _MarketFooterSection(),
      ],
    );
  }
}

class _MarketHeaderSection extends StatelessWidget {
  const _MarketHeaderSection();
  @override
  Widget build(BuildContext context) {
    final mood = context.select<AppState, Sentiment>((s) => s.marketMood);
    final fetchedAt = context.select<AppState, DateTime?>((s) => s.snapshot?.fetchedAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        const Text('Market mood: ', style: TextStyle(fontWeight: FontWeight.w600)),
        SentimentChip(mood),
        const Spacer(),
        if (fetchedAt != null)
          Text('Updated ${DateFormat.jm().format(fetchedAt)}',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
      ]),
    );
  }
}

class _MarketIndicesSection extends StatelessWidget {
  const _MarketIndicesSection();
  @override
  Widget build(BuildContext context) {
    final indices = context.select<AppState, List<MarketIndex>>((s) => s.snapshot?.indices ?? const []);
    return Column(
      children: indices.map((i) => _IndexTile(index: i)).toList(),
    );
  }
}

class _MarketSuggestionsSection extends StatelessWidget {
  const _MarketSuggestionsSection();
  @override
  Widget build(BuildContext context) {
    final suggestions = context.select<AppState, List<StockSuggestion>>((s) => s.stockSuggestions);
    return SuggestionStrip(
      title: 'Which share to buy / sell today',
      items: suggestions,
      onSeeAll: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SuggestionsScreen())),
    );
  }
}

class _MarketGainersSection extends StatelessWidget {
  const _MarketGainersSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<StockQuote> gainers})>(
      selector: (_, s) => (gainers: s.snapshot?.gainers ?? const []),
      shouldRebuild: (prev, next) =>
          prev.gainers.length != next.gainers.length ||
          (prev.gainers.isNotEmpty && next.gainers.isNotEmpty && prev.gainers[0].changePct != next.gainers[0].changePct),
      builder: (_, data, __) => Column(
        children: data.gainers.map((q) => StockTile(quote: q)).toList(),
      ),
    );
  }
}

class _MarketLosersSection extends StatelessWidget {
  const _MarketLosersSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<StockQuote> losers})>(
      selector: (_, s) => (losers: s.snapshot?.losers ?? const []),
      shouldRebuild: (prev, next) =>
          prev.losers.length != next.losers.length ||
          (prev.losers.isNotEmpty && next.losers.isNotEmpty && prev.losers[0].changePct != next.losers[0].changePct),
      builder: (_, data, __) => Column(
        children: data.losers.map((q) => StockTile(quote: q)).toList(),
      ),
    );
  }
}

class _MarketFooterSection extends StatelessWidget {
  const _MarketFooterSection();
  @override
  Widget build(BuildContext context) {
    final isLive = context.select<AppState, bool>((s) => s.snapshot?.isLive ?? false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        isLive
            ? 'Source: IndianAPI trending data. Prices may be delayed.'
            : 'Market data unavailable. Showing offline/stale state.',
        style: const TextStyle(fontSize: 11, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _IndexTile extends StatelessWidget {
  const _IndexTile({required this.index});
  final MarketIndex index;

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      if (index.open != null) ('Open', num2.format(index.open)),
      if (index.high != null) ('High', num2.format(index.high)),
      if (index.low != null) ('Low', num2.format(index.low)),
      if (index.previousClose != null) ('Prev Close', num2.format(index.previousClose)),
    ];

    return DetailedChartCard(
      title: index.name,
      subtitle: index.exchange,
      value: num2.format(index.last),
      changePct: index.changePct,
      change: index.change,
      currency: '₹',
      points: index.sparkline.isNotEmpty
          ? index.sparkline
          : [index.previousClose ?? index.last * 0.98, index.last],
      labels: const ['AUG 1', 'AUG 6', 'AUG 12'],
      stats: stats,
    );
  }
}

class StockTile extends StatelessWidget {
  const StockTile({super.key, required this.quote});
  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final c = gainColor(context, quote.isUp);
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: c.withValues(alpha: .12),
        child: Text(quote.symbol.substring(0, quote.symbol.length.clamp(0, 2)),
            style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
      title: Text(quote.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(quote.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(priceFmt(quote), style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('${quote.isUp ? '+' : ''}${quote.changePct.toStringAsFixed(2)}%',
            style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }
}
