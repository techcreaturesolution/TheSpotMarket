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
    // Only rebuild when IPO data or live status changes — not every market tick.
    return Selector<AppState, ({List<Ipo> ipos, bool ipoIsLive, bool ipoLoading})>(
      selector: (_, s) => (
        ipos: s.ipos,
        ipoIsLive: s.ipoIsLive,
        ipoLoading: s.ipoLoading,
      ),
      shouldRebuild: (prev, next) =>
          prev.ipoIsLive != next.ipoIsLive ||
          prev.ipoLoading != next.ipoLoading ||
          prev.ipos.length != next.ipos.length,
      builder: (ctx, data, __) {
        List<Ipo> filter(List<Ipo> list) =>
            _mainboardOnly ? list.where((i) => !i.isSme).toList() : list;

        final lists = [
          filter(data.ipos),
          filter(data.ipos.where((i) => i.status == IpoStatus.open).toList()),
          filter(data.ipos.where((i) => i.status == IpoStatus.upcoming).toList()),
          filter(data.ipos.where((i) => i.status == IpoStatus.closed).toList()),
          filter(data.ipos.where((i) => i.status == IpoStatus.listed).toList()),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              const Text('IPO Analysis'),
              const SizedBox(width: 8),
              LiveBadge(live: data.ipoIsLive),
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
            children: [
              _IpoTabListView(key: const PageStorageKey('tab_all'), list: lists[0], emptyMessage: 'No IPOs found'),
              _IpoTabListView(key: const PageStorageKey('tab_open'), list: lists[1], emptyMessage: 'No IPOs currently open for subscription\nCheck the "Upcoming" tab for new issues'),
              _IpoTabListView(key: const PageStorageKey('tab_upcoming'), list: lists[2], emptyMessage: 'No upcoming IPOs found'),
              _IpoTabListView(key: const PageStorageKey('tab_closed'), list: lists[3], emptyMessage: 'No closed IPOs found'),
              _IpoTabListView(key: const PageStorageKey('tab_listed'), list: lists[4], emptyMessage: 'No listed IPOs found'),
            ],
          ),
        );
      },
    );
  }
}

class _IpoTabListView extends StatefulWidget {
  const _IpoTabListView({
    super.key,
    required this.list,
    required this.emptyMessage,
  });

  final List<Ipo> list;
  final String emptyMessage;

  @override
  State<_IpoTabListView> createState() => _IpoTabListViewState();
}

class _IpoTabListViewState extends State<_IpoTabListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final list = widget.list;
    final ipoLoading = context.select<AppState, bool>((s) => s.ipoLoading);
    final hasIpos = context.select<AppState, bool>((s) => s.ipos.isNotEmpty);

    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().loadIpos(force: true),
      child: (list.isEmpty && ipoLoading && !hasIpos)
          ? ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              children: const [
                IpoCardSkeleton(),
                IpoCardSkeleton(),
                IpoCardSkeleton(),
                IpoCardSkeleton(),
              ],
            )
          : list.isEmpty
              ? ListView(children: [
                  const SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.inbox_outlined,
                    title: widget.emptyMessage,
                  ),
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
    );
  }
}

class IpoCard extends StatelessWidget {
  const IpoCard({super.key, required this.ipo});
  final Ipo ipo;

  @override
  Widget build(BuildContext context) {
    // Score is computed once per build but ipo object doesn't change frequently.
    // Use context.select for watchlist only — avoids rebuilding on market ticks.
    final isWatched = context.select<AppState, bool>((s) => s.isWatched(ipo.id));
    final score = AiService.scoreIpo(ipo);
    final gain = ipo.expectedListingGainPct;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.09 : 0.7),
            const Color(0xFF0C2016).withValues(alpha: isDark ? 0.40 : 0.4),
            const Color(0xFF030D08).withValues(alpha: isDark ? 0.70 : 0.05),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => openIpo(context, ipo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title, Exchange/Sector & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ipo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (ipo.isSme)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${ipo.sector} • ${ipo.exchange}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(ipo.status),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.read<AppState>().toggleWatch(ipo.id),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isWatched ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isWatched
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Compact Financial Details Row (Price, Lot, Issue Size, Listing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _CompactStat(
                      'Price',
                      ipo.priceMin > 0
                          ? (ipo.priceMin == ipo.priceMax
                              ? inr.format(ipo.priceMin)
                              : '${inr.format(ipo.priceMin)}–${inr.format(ipo.priceMax)}')
                          : 'TBA',
                    ),
                    _CompactStat('Lot', ipo.lotSize != null && ipo.lotSize! > 0 ? '${ipo.lotSize} sh' : '—'),
                    _CompactStat('Issue', ipo.issuePrice != null && ipo.issuePrice! > 0 ? inr.format(ipo.issuePrice!) : '—'),
                    _CompactStat(
                      ipo.status == IpoStatus.listed ? 'Status' : 'Listing',
                      ipo.listingDate != null
                          ? dateFmt.format(ipo.listingDate!)
                          : (ipo.status == IpoStatus.listed ? 'Listed' : '—'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Footer Row: Sub, GMP, Score Badge
              Row(
                children: [
                  if (ipo.totalSubscription > 0)
                    _CompactBadge(
                      Icons.people_outline,
                      '${ipo.totalSubscription.toStringAsFixed(1)}x sub',
                      Colors.blue,
                    ),
                  if (gain != null) ...[
                    const SizedBox(width: 6),
                    _CompactBadge(
                      gain >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      'GMP ${inr.format(ipo.gmp)} (${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(0)}%)',
                      gainColor(context, gain >= 0),
                    ),
                  ],
                  const Spacer(),
                  _ScoreBadge(score),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );
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
    // Only watch watchlist changes — IPO data and market ticks don't affect this screen.
    final s = context.read<AppState>();
    final isWatched = context.select<AppState, bool>((st) => st.isWatched(ipoId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            icon: Icon(isWatched ? Icons.bookmark : Icons.bookmark_border),
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
          // AI analysis card (Light Blue background with dark readable text)
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SpotAI IPO Score',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${score.score}/100',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score.score / 100,
                    minHeight: 8,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  score.verdict,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                ...score.reasons.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            r,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rule-based score. Not SEBI-registered investment advice.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Section('Issue details', [
            KeyValueRow(
              'Price band',
              ipo.priceMin > 0
                  ? (ipo.priceMin == ipo.priceMax
                      ? inr.format(ipo.priceMin)
                      : '${inr.format(ipo.priceMin)} – ${inr.format(ipo.priceMax)}')
                  : 'TBA',
            ),
            if (ipo.issuePrice != null && ipo.issuePrice! > 0)
              KeyValueRow('Issue price', inr.format(ipo.issuePrice!)),
            KeyValueRow('Lot size', ipo.lotSize != null && ipo.lotSize! > 0 ? '${ipo.lotSize} shares' : '—'),
            KeyValueRow('Min. investment (1 lot)', ipo.minInvestment > 0 ? inr.format(ipo.minInvestment) : '—'),
            if (ipo.minInvestment > 0)
              KeyValueRow('Max retail lots', '${(200000 / ipo.minInvestment).floor()} lots'),
            KeyValueRow('Issue size', ipo.issueSizeCr > 0 ? '${inr.format(ipo.issueSizeCr)} Cr' : '—'),
            KeyValueRow('Exchange', ipo.exchange),
            KeyValueRow('Registrar', ipo.registrar),
          ]),
          _Section('Timeline', [
            KeyValueRow('Open date', ipo.openDate != null ? dateFullFmt.format(ipo.openDate!) : 'TBA'),
            KeyValueRow('Close date', ipo.closeDate != null ? dateFullFmt.format(ipo.closeDate!) : 'TBA'),
            KeyValueRow('Allotment date', ipo.allotmentDate != null ? dateFullFmt.format(ipo.allotmentDate!) : '—'),
            KeyValueRow('Listing date', ipo.listingDate != null ? dateFullFmt.format(ipo.listingDate!) : '—'),
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
