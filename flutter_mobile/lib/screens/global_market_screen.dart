import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../services/global_market_service.dart';
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
    // Only watch global-related state, not market indices that tick every second.
    final isLive = context.select<AppState, bool>((s) => s.globalSnapshot?.isLive ?? false);
    final hasSnap = context.select<AppState, bool>((s) => s.globalSnapshot != null);
    final globalLoading = context.select<AppState, bool>((s) => s.globalLoading && s.globalSnapshot == null);
    final loadGlobal = context.read<AppState>().loadGlobal;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Text('International Market'),
            const SizedBox(width: 8),
            if (hasSnap) LiveBadge(live: isLive),
          ]),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: loadGlobal)],
          bottom: const TabBar(
            indicatorColor: Color(0xFF10B981),
            indicatorWeight: 3,
            labelColor: Color(0xFF34D399),
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
            tabs: [
              Tab(text: 'Indices'),
              Tab(text: 'Buy / Sell'),
              Tab(text: 'News'),
            ],
          ),
        ),
        body: globalLoading
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

class _GlobalIndicesTab extends StatefulWidget {
  const _GlobalIndicesTab();

  @override
  State<_GlobalIndicesTab> createState() => _GlobalIndicesTabState();
}

class _GlobalIndicesTabState extends State<_GlobalIndicesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Only watch global snapshot data — avoids rebuilding on NSE market ticks.
    final snap = context.select<AppState, GlobalSnapshot?>((s) => s.globalSnapshot);
    final globalIndices = context.select<AppState, List<MarketIndex>>((s) => s.globalIndices);
    final globalStocks = context.select<AppState, List<StockQuote>>((s) => s.globalStocks);
    final globalMood = context.select<AppState, Sentiment>((s) => s.globalMood);
    final globalLoading = context.select<AppState, bool>((s) => s.globalLoading);
    final isInitialLoading = context.select<AppState, bool>((s) => s.isInitialLoading);
    final loadGlobal = context.read<AppState>().loadGlobal;

    if (globalIndices.isEmpty && (globalLoading || isInitialLoading)) {
      return RefreshIndicator(
        onRefresh: loadGlobal,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ShimmerBox(width: 140, height: 18, borderRadius: 4),
            ),
            StockTileSkeleton(),
            StockTileSkeleton(),
            StockTileSkeleton(),
            StockTileSkeleton(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ShimmerBox(width: 120, height: 18, borderRadius: 4),
            ),
            StockTileSkeleton(),
            StockTileSkeleton(),
          ],
        ),
      );
    }

    final groups = <String, List<MarketIndex>>{};
    for (final i in globalIndices) {
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
      onRefresh: loadGlobal,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              const Text('Global mood: ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
              SentimentChip(globalMood),
              const Spacer(),
              if (snap != null)
                Text('Updated ${DateFormat.jm().format(snap.fetchedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
            ]),
          ),
          for (final e in groups.entries) ...[
            SectionHeader(e.key),
            ...e.value.map((i) => _GlobalIndexTile(index: i)),
            if (e.key == 'United States') const NativeAdCard(),
          ],
          const SectionHeader('World Stocks'),
          ...globalStocks.map((q) => StockTile(quote: q)),
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
      points: index.sparkline.isNotEmpty
          ? index.sparkline
          : [index.previousClose ?? index.last * 0.98, index.last],
      labels: const ['AUG 1', 'AUG 6', 'AUG 12'],
      stats: stats,
    );
  }
}

class _GlobalIdeasTab extends StatefulWidget {
  const _GlobalIdeasTab();

  @override
  State<_GlobalIdeasTab> createState() => _GlobalIdeasTabState();
}

class _GlobalIdeasTabState extends State<_GlobalIdeasTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = context.select<AppState, List<StockSuggestion>>((s) => s.globalSuggestions);
    final loadGlobal = context.read<AppState>().loadGlobal;
    return RefreshIndicator(
      onRefresh: loadGlobal,
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

class _GlobalNewsTab extends StatefulWidget { 
  const _GlobalNewsTab();

  @override
  State<_GlobalNewsTab> createState() => _GlobalNewsTabState();
}

class _GlobalNewsTabState extends State<_GlobalNewsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = context.select<AppState, List<NewsArticle>>((s) => s.globalNews);
    final loadGlobal = context.read<AppState>().loadGlobal;
    return RefreshIndicator(
      onRefresh: loadGlobal,
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
