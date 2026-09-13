import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'market_screen.dart';
import 'news_screen.dart';
import 'suggestions_screen.dart';

/// International Market tab: global indices / commodities / forex, world
/// stock buy-sell ideas and international market news.
class GlobalMarketScreen extends StatelessWidget {
  const GlobalMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Text('International Market'),
            const SizedBox(width: 8),
            if (s.globalSnapshot != null) LiveBadge(live: s.globalSnapshot!.isLive),
          ]),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: s.loadGlobal)],
          bottom: const TabBar(tabs: [
            Tab(text: 'Indices'),
            Tab(text: 'Buy / Sell'),
            Tab(text: 'News'),
          ]),
        ),
        body: s.globalLoading && s.globalSnapshot == null
            ? const Center(child: CircularProgressIndicator())
            : const TabBarView(children: [
                _GlobalIndicesTab(),
                _GlobalIdeasTab(),
                _GlobalNewsTab(),
              ]),
      ),
    );
  }
}

class _GlobalIndicesTab extends StatelessWidget {
  const _GlobalIndicesTab();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final snap = s.globalSnapshot;
    final groups = <String, List<MarketIndex>>{};
    for (final i in s.globalIndices) {
      final g = switch (i.exchange) {
        'Commodity' => 'Commodities',
        'Forex' => 'Currency',
        'USA' => 'United States',
        'UK' || 'Germany' => 'Europe',
        _ => 'Asia-Pacific',
      };
      groups.putIfAbsent(g, () => []).add(i);
    }
    return RefreshIndicator(
      onRefresh: s.loadGlobal,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Text('Global mood: ', style: TextStyle(fontWeight: FontWeight.w600)),
              SentimentChip(s.globalMood),
              const Spacer(),
              if (snap != null)
                Text('Updated ${DateFormat.jm().format(snap.fetchedAt)}',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            ]),
          ),
          for (final e in groups.entries) ...[
            SectionHeader(e.key),
            ...e.value.map((i) => _GlobalIndexTile(index: i)),
            if (e.key == 'United States') const NativeAdCard(),
          ],
          const SectionHeader('World Stocks'),
          ...s.globalStocks.map((q) => StockTile(quote: q)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              snap?.isLive ?? false
                  ? 'Source: Yahoo Finance public data. Quotes may be delayed by 15–20 minutes.'
                  : 'Showing sample data – live global feed unreachable. Configure BACKEND_URL for a reliable feed.',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalIndexTile extends StatelessWidget {
  const _GlobalIndexTile({required this.index});
  final MarketIndex index;

  @override
  Widget build(BuildContext context) {
    final c = gainColor(context, index.isUp);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(index.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(index.exchange, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            ]),
          ),
          if (index.sparkline.isNotEmpty)
            SizedBox(width: 80, child: Sparkline(index.sparkline, up: index.isUp, height: 28)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(num2.format(index.last), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            Text(
              '${index.isUp ? '+' : ''}${num2.format(index.change)} (${index.isUp ? '+' : ''}${index.changePct.toStringAsFixed(2)}%)',
              style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _GlobalIdeasTab extends StatelessWidget {
  const _GlobalIdeasTab();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.globalSuggestions;
    return RefreshIndicator(
      onRefresh: s.loadGlobal,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const SuggestionDisclaimer(),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: EmptyState(icon: Icons.insights, title: 'No global ideas yet', subtitle: 'Pull to refresh'),
            ),
          for (var i = 0; i < items.length; i++) ...[
            SuggestionCard(s: items[i]),
            if (i == 3) const NativeAdCard(),
          ],
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SuggestionsScreen(global: true))),
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter Buy / Sell / Hold'),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlobalNewsTab extends StatelessWidget {
  const _GlobalNewsTab();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.globalNews;
    return RefreshIndicator(
      onRefresh: s.loadGlobal,
      child: items.isEmpty
          ? ListView(children: const [
              SizedBox(height: 120),
              EmptyState(icon: Icons.public, title: 'No international news yet', subtitle: 'Pull to refresh'),
            ])
          : ListView.builder(
              padding: const EdgeInsets.only(top: 6, bottom: 96),
              itemCount: items.length + items.length ~/ 6,
              itemBuilder: (_, i) {
                if (i > 0 && i % 7 == 6) return const NativeAdCard();
                return NewsTile(article: items[i - i ~/ 7]);
              },
            ),
    );
  }
}
