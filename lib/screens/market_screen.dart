import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'suggestions_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final snap = s.snapshot;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Share Market'),
          const SizedBox(width: 8),
          if (snap != null) LiveBadge(live: snap.isLive),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: s.loadMarket),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: s.loadMarket,
        child: snap == null
            ? ListView(children: [
                const SizedBox(height: 160),
                Center(
                  child: s.marketLoading
                      ? const CircularProgressIndicator()
                      : EmptyState(
                          icon: Icons.cloud_off,
                          title: 'Could not load market data',
                          subtitle: s.marketError,
                          action: FilledButton(onPressed: s.loadMarket, child: const Text('Retry')),
                        ),
                ),
              ])
            : ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(children: [
                      const Text('Market mood: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      SentimentChip(s.marketMood),
                      const Spacer(),
                      Text('Updated ${DateFormat.jm().format(snap.fetchedAt)}',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                    ]),
                  ),
                  const SectionHeader('NSE & BSE Indices'),
                  ...snap.indices.map((i) => _IndexTile(index: i)),
                  SuggestionStrip(
                    title: 'Which share to buy / sell today',
                    items: s.stockSuggestions,
                    onSeeAll: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SuggestionsScreen())),
                  ),
                  const SectionHeader('Top Gainers (Nifty 50)'),
                  ...snap.gainers.map((q) => StockTile(quote: q)),
                  const NativeAdCard(),
                  const SectionHeader('Top Losers (Nifty 50)'),
                  ...snap.losers.map((q) => StockTile(quote: q)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      snap.isLive
                          ? 'Source: NSE India public data. Prices may be delayed by up to 15 minutes.'
                          : 'Showing sample data – live NSE feed unreachable. Configure BACKEND_URL for a reliable feed.',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _IndexTile extends StatelessWidget {
  const _IndexTile({required this.index});
  final MarketIndex index;

  @override
  Widget build(BuildContext context) {
    final c = gainColor(context, index.isUp);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(index.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(index.exchange, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
              ]),
            ),
            if (index.sparkline.isNotEmpty)
              SizedBox(width: 90, child: Sparkline(index.sparkline, up: index.isUp, height: 32)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(num2.format(index.last), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(
                '${index.isUp ? '+' : ''}${num2.format(index.change)} (${index.isUp ? '+' : ''}${index.changePct.toStringAsFixed(2)}%)',
                style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ]),
          ]),
          if (index.open != null || index.high != null || index.low != null) ...[
            const Divider(height: 16),
            Row(children: [
              _Mini('Open', index.open),
              _Mini('High', index.high),
              _Mini('Low', index.low),
              _Mini('Prev', index.previousClose),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.label, this.value);
  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
          Text(value == null ? '—' : num2.format(value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
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
