import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ad_service.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'allotment_screen.dart';

void openIpo(BuildContext context, Ipo ipo) {
  AdService.instance.recordDetailView();
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => IpoDetailScreen(ipoId: ipo.id)));
}

class IpoListScreen extends StatefulWidget {
  const IpoListScreen({super.key});

  @override
  State<IpoListScreen> createState() => _IpoListScreenState();
}

class _IpoListScreenState extends State<IpoListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 5, vsync: this);
  bool _mainboardOnly = false;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    List<Ipo> filter(List<Ipo> list) =>
        _mainboardOnly ? list.where((i) => !i.isSme).toList() : list;

    final lists = [
      filter(s.ipos),
      filter(s.iposWhere(IpoStatus.open)),
      filter(s.iposWhere(IpoStatus.upcoming)),
      filter(s.iposWhere(IpoStatus.closed)),
      filter(s.iposWhere(IpoStatus.listed)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('IPO Analysis'),
          const SizedBox(width: 8),
          LiveBadge(live: s.ipoIsLive),
        ]),
        actions: [
          IconButton(
            tooltip: _mainboardOnly ? 'Show SME IPOs' : 'Hide SME IPOs',
            icon: Icon(_mainboardOnly ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _mainboardOnly = !_mainboardOnly),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'All (${lists[0].length})'),
            Tab(text: 'Open (${lists[1].length})'),
            Tab(text: 'Upcoming (${lists[2].length})'),
            Tab(text: 'Closed (${lists[3].length})'),
            Tab(text: 'Listed (${lists[4].length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: lists
            .map((list) => RefreshIndicator(
                  onRefresh: s.loadIpos,
                  child: list.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 120),
                          EmptyState(icon: Icons.inbox_outlined, title: 'No IPOs in this category'),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 96),
                          itemCount: list.length + (list.length > 3 ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == 3 && list.length > 3) return const NativeAdCard();
                            final idx = i > 3 ? i - 1 : i;
                            return IpoCard(ipo: list[idx]);
                          },
                        ),
                ))
            .toList(),
      ),
    );
  }
}

class IpoCard extends StatelessWidget {
  const IpoCard({super.key, required this.ipo});
  final Ipo ipo;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final score = AiService.scoreIpo(ipo);
    final gain = ipo.expectedListingGainPct;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openIpo(context, ipo),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ipo.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('${ipo.sector} · ${ipo.exchange}${ipo.isSme ? ' · SME' : ''}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                ]),
              ),
              StatusChip(ipo.status),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(s.isWatched(ipo.id) ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () => s.toggleWatch(ipo.id),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _Stat('Price band', '${inr.format(ipo.priceMin)}–${inr.format(ipo.priceMax)}'),
              _Stat('Lot', '${ipo.lotSize} sh'),
              _Stat('Issue size', '${inr.format(ipo.issueSizeCr)} Cr'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _Stat('Open', dateFmt.format(ipo.openDate)),
              _Stat('Close', dateFmt.format(ipo.closeDate)),
              _Stat('Listing', dateFmt.format(ipo.listingDate)),
            ]),
            const Divider(height: 20),
            Row(children: [
              if (ipo.totalSubscription > 0)
                _Pill(Icons.people_outline, '${ipo.totalSubscription.toStringAsFixed(1)}x sub'),
              if (gain != null)
                _Pill(
                  gain >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  'GMP ${inr.format(ipo.gmp)} (${gain.toStringAsFixed(0)}%)',
                  color: gainColor(context, gain >= 0),
                ),
              const Spacer(),
              _ScoreBadge(score),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.text, {this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
      ]),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge(this.score);
  final IpoScore score;

  Color get color => score.score >= 75
      ? const Color(0xFF16A34A)
      : score.score >= 60
          ? const Color(0xFF65A30D)
          : score.score >= 45
              ? const Color(0xFFD97706)
              : const Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome, size: 14),
          const SizedBox(width: 4),
          Text('AI ${score.score}', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ]),
      );
}

class IpoDetailScreen extends StatelessWidget {
  const IpoDetailScreen({super.key, required this.ipoId});
  final String ipoId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final ipo = s.ipoById(ipoId);
    if (ipo == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.error_outline, title: 'IPO not found'));
    }
    final score = AiService.scoreIpo(ipo);
    final gain = ipo.expectedListingGainPct;

    return Scaffold(
      appBar: AppBar(
        title: Text(ipo.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(s.isWatched(ipo.id) ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => s.toggleWatch(ipo.id),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(children: [
            StatusChip(ipo.status),
            const SizedBox(width: 8),
            Text('${ipo.sector} · ${ipo.exchange}', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ]),
          const SizedBox(height: 12),
          // AI analysis card
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.auto_awesome, size: 18),
                  const SizedBox(width: 6),
                  const Text('SpotAI IPO Score', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${score.score}/100', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ]),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: score.score / 100, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 8),
                Text(score.verdict, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                ...score.reasons.map((r) => Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('• '),
                        Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                      ]),
                    )),
                const SizedBox(height: 6),
                const Text('Rule-based score. Not SEBI-registered investment advice.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          _Section('Issue details', [
            KeyValueRow('Price band', '${inr.format(ipo.priceMin)} – ${inr.format(ipo.priceMax)}'),
            KeyValueRow('Lot size', '${ipo.lotSize} shares'),
            KeyValueRow('Min. investment (1 lot)', inr.format(ipo.minInvestment)),
            KeyValueRow('Max retail lots', '${(200000 / ipo.minInvestment).floor()} lots'),
            KeyValueRow('Issue size', '${inr.format(ipo.issueSizeCr)} Cr'),
            KeyValueRow('Exchange', ipo.exchange),
            KeyValueRow('Registrar', ipo.registrar),
          ]),
          _Section('Timeline', [
            KeyValueRow('Open date', dateFullFmt.format(ipo.openDate)),
            KeyValueRow('Close date', dateFullFmt.format(ipo.closeDate)),
            KeyValueRow('Allotment date', dateFullFmt.format(ipo.allotmentDate)),
            KeyValueRow('Listing date', dateFullFmt.format(ipo.listingDate)),
          ]),
          if (ipo.subscriptionRetail != null || ipo.subscriptionQib != null || ipo.subscriptionNii != null)
            _Section('Subscription', [
              _SubBar('QIB', ipo.subscriptionQib),
              _SubBar('NII / HNI', ipo.subscriptionNii),
              _SubBar('Retail', ipo.subscriptionRetail),
              KeyValueRow('Overall', '${ipo.totalSubscription.toStringAsFixed(2)}x'),
            ]),
          _Section('Grey market & listing', [
            KeyValueRow('GMP', ipo.gmp == null ? '—' : inr.format(ipo.gmp), valueColor: gain == null ? null : gainColor(context, gain >= 0)),
            KeyValueRow('Expected listing', gain == null ? '—' : '${inr.format(ipo.priceMax + (ipo.gmp ?? 0))} (${gain.toStringAsFixed(1)}%)'),
            if (ipo.listingPrice != null)
              KeyValueRow('Actual listing price', inr.format(ipo.listingPrice),
                  valueColor: gainColor(context, ipo.listingPrice! >= ipo.priceMax)),
            if (ipo.listingPrice != null)
              KeyValueRow('Listing gain', '${((ipo.listingPrice! - ipo.priceMax) / ipo.priceMax * 100).toStringAsFixed(1)}%'),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('GMP is unofficial and unregulated; it can change any time.',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ]),
          _Section('About the company', [Text(ipo.about, style: const TextStyle(height: 1.4))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: ipo.status == IpoStatus.upcoming || ipo.status == IpoStatus.open
                    ? null
                    : () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AllotmentCheckScreen(ipo: ipo))),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Check allotment'),
              ),
            ),
            const SizedBox(width: 8),
            if (ipo.registrarUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(ipo.registrarUrl), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Registrar'),
              ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            ...children,
          ]),
        ),
      );
}

class _SubBar extends StatelessWidget {
  const _SubBar(this.label, this.value);
  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    final v = value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text('${v.toStringAsFixed(2)}x', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: (v / 50).clamp(0.02, 1.0),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          color: v >= 1 ? const Color(0xFF16A34A) : Colors.orange,
        ),
      ]),
    );
  }
}
