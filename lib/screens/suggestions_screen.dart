import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

/// Buy / sell / hold ideas. [global] switches between the Indian large-cap
/// universe and the international stock list.
class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key, this.global = false});
  final bool global;

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  TradeAction? _filter;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final all = widget.global ? s.globalSuggestions : s.stockSuggestions;
    final loading = widget.global ? s.globalLoading : s.marketLoading;
    final items = _filter == null ? all : all.where((e) => e.action == _filter).toList();
    final buys = all.where((e) => e.action == TradeAction.buy).length;
    final sells = all.where((e) => e.action == TradeAction.sell).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.global ? 'Global Buy / Sell Ideas' : 'Buy / Sell Ideas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.global ? s.loadGlobal : () => Future.wait([s.loadMarket(), s.loadNews()]),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.global ? s.loadGlobal : () => Future.wait([s.loadMarket(), s.loadNews()]),
        child: loading && all.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Wrap(spacing: 6, children: [
                      ChoiceChip(label: Text('All (${all.length})'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
                      ChoiceChip(label: Text('Buy ($buys)'), selected: _filter == TradeAction.buy, onSelected: (_) => setState(() => _filter = TradeAction.buy)),
                      ChoiceChip(label: Text('Sell ($sells)'), selected: _filter == TradeAction.sell, onSelected: (_) => setState(() => _filter = TradeAction.sell)),
                      ChoiceChip(label: const Text('Hold'), selected: _filter == TradeAction.hold, onSelected: (_) => setState(() => _filter = TradeAction.hold)),
                    ]),
                  ),
                  const SuggestionDisclaimer(),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: EmptyState(icon: Icons.insights, title: 'No ideas for this filter'),
                    ),
                  for (var i = 0; i < items.length; i++) ...[
                    SuggestionCard(s: items[i]),
                    if (i == 3) const NativeAdCard(),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Compact horizontal preview used on the dashboard / market tabs.
class SuggestionStrip extends StatelessWidget {
  const SuggestionStrip({super.key, required this.items, required this.onSeeAll, this.title = 'SpotAI Buy / Sell Ideas'});
  final List<StockSuggestion> items;
  final VoidCallback onSeeAll;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final picks = [
      ...items.where((e) => e.action == TradeAction.buy).take(3),
      ...items.where((e) => e.action == TradeAction.sell).take(3),
    ];
    if (picks.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title, action: 'See all', onAction: onSeeAll),
      SizedBox(
        height: 108,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: picks.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final p = picks[i];
            final q = p.quote;
            final c = gainColor(context, q.isUp);
            return SizedBox(
              width: 170,
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        ActionChipLabel(p.action),
                        const Spacer(),
                        Text('${p.confidence}%', style: TextStyle(fontSize: 11, color: p.action.color, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Text(q.symbol, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(q.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                      const Spacer(),
                      Row(children: [
                        Text(priceFmt(q), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${q.isUp ? '+' : ''}${q.changePct.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w700)),
                      ]),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
