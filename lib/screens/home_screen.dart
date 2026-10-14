import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'ai_chat_screen.dart';
import 'allotment_screen.dart';
import 'auth_screen.dart';
import 'global_market_screen.dart';
import 'ipo_screens.dart';
import 'market_screen.dart';
import 'news_screen.dart';
import 'settings_screen.dart';
import 'suggestions_screen.dart';

import '../widgets/curved_nav_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  AppState? _appState;

  void switchTab(int i) => setState(() => _index = i);

  static const _tabs = [
    DashboardScreen(),
    IpoListScreen(),
    MarketScreen(),
    GlobalMarketScreen(),
    NewsScreen(),
    AllotmentScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      _appState = state;
      state.addListener(_onAppStateChanged);
      state.refreshAll();
      state.startAutoRefresh(interval: const Duration(seconds: 15));
    });
  }

  void _onAppStateChanged() {
    final state = _appState;
    if (state == null || !mounted) return;
    final err = state.consumeLastErrorNotice();
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  err,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: const Color(0xFF10B981),
            onPressed: () => state.refreshAll(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _appState?.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _index, children: _tabs),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'spotai',
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AiChatScreen())),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('SpotAI'),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BannerAdWidget(),
            CurvedNotchedNavBar(
              selectedIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: const [
                NavItemData(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Home'),
                NavItemData(icon: Icons.rocket_launch_outlined, selectedIcon: Icons.rocket_launch, label: 'IPOs'),
                NavItemData(icon: Icons.show_chart_outlined, selectedIcon: Icons.show_chart, label: 'Market'),
                NavItemData(icon: Icons.public_outlined, selectedIcon: Icons.public, label: 'Global'),
                NavItemData(icon: Icons.newspaper_outlined, selectedIcon: Icons.newspaper, label: 'News'),
                NavItemData(icon: Icons.fact_check_outlined, selectedIcon: Icons.fact_check, label: 'Allotment'),
              ],
            ),
          ],
        ),
      );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isInitialLoading = context.select<AppState, bool>((s) => s.isInitialLoading);
    final hasData = context.select<AppState, bool>((s) => s.hasDashboardData);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          Builder(builder: (context) {
            final auth = context.watch<AuthService>();
            if (!auth.isAvailable) return const SizedBox.shrink();
            return IconButton(
              tooltip: auth.isSignedIn ? auth.displayName : 'Sign in',
              icon: auth.isSignedIn
                  ? CircleAvatar(radius: 14, child: Text(auth.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 13)))
                  : const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => auth.isSignedIn ? const SettingsScreen() : const AuthScreen())),
            );
          }),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      // Use context.read so the scaffold itself doesn't rebuild every second.
      body: RefreshIndicator(
        onRefresh: context.read<AppState>().refreshAll,
        child: (isInitialLoading && !hasData)
            ? const DashboardLoadingSkeleton()
            : const _DashboardBody(),
      ),
    );
  }
}

/// Body with each section using a narrow Selector — only rebuilds when
/// its specific slice of AppState actually changes.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: const [
        _IndexStripSection(),
        _AiBriefCard(),
        _SuggestionStripSection(),
        _OpenIpoSection(),
        _UpcomingIpoSection(),
        _TopGainersSection(),
        _TopLosersSection(),
        _LatestNewsSection(),
        _DashboardFooter(),
      ],
    );
  }
}

// --- Index strip section: rebuilds only when market indices change ---
class _IndexStripSection extends StatelessWidget {
  const _IndexStripSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<MarketIndex> indices, bool loading, bool isLive})>(
      selector: (_, s) => (
        indices: s.indices,
        loading: s.marketLoading,
        isLive: s.snapshot?.isLive ?? false,
      ),
      shouldRebuild: (prev, next) =>
          prev.loading != next.loading ||
          prev.isLive != next.isLive ||
          prev.indices.length != next.indices.length ||
          (prev.indices.isNotEmpty &&
              next.indices.isNotEmpty &&
              prev.indices[0].last != next.indices[0].last),
      builder: (_, data, __) => _IndexStrip(
        indices: data.indices,
        loading: data.loading,
        isLive: data.isLive,
      ),
    );
  }
}

// --- Suggestion strip: rebuilds only when suggestions change ---
class _SuggestionStripSection extends StatelessWidget {
  const _SuggestionStripSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, List<StockSuggestion>>(
      selector: (_, s) => s.stockSuggestions,
      shouldRebuild: (prev, next) => prev != next,
      builder: (ctx, items, __) => SuggestionStrip(
        items: items,
        onSeeAll: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const SuggestionsScreen())),
      ),
    );
  }
}

// --- Open IPO section: rebuilds only when IPO list changes ---
class _OpenIpoSection extends StatelessWidget {
  const _OpenIpoSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<Ipo> open, bool loading, bool ipoIsLive, bool hasIpos})>(
      selector: (_, s) {
        final open = s.iposWhere(IpoStatus.open);
        return (
          open: open,
          loading: s.ipoLoading,
          ipoIsLive: s.ipoIsLive,
          hasIpos: s.ipos.isNotEmpty,
        );
      },
      shouldRebuild: (prev, next) =>
          prev.loading != next.loading ||
          prev.ipoIsLive != next.ipoIsLive ||
          prev.hasIpos != next.hasIpos ||
          prev.open.length != next.open.length,
      builder: (ctx, data, __) {
        if (data.loading && !data.hasIpos) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ShimmerBox(width: 130, height: 18, borderRadius: 4),
              ),
              IpoCardSkeleton(),
              IpoCardSkeleton(),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'Open IPOs (${data.open.length})',
              action: 'See all',
              onAction: () => ctx.findAncestorStateOfType<_HomeShellState>()?.switchTab(1),
              isLive: data.ipoIsLive,
            ),
            if (data.open.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No IPO is open for subscription right now.'),
              )
            else
              ...data.open.take(3).map((i) => IpoCard(ipo: i)),
          ],
        );
      },
    );
  }
}

// --- Upcoming IPO section: rebuilds only when upcoming IPOs change ---
class _UpcomingIpoSection extends StatelessWidget {
  const _UpcomingIpoSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<Ipo> upcoming, bool ipoIsLive})>(
      selector: (_, s) => (
        upcoming: s.iposWhere(IpoStatus.upcoming),
        ipoIsLive: s.ipoIsLive,
      ),
      shouldRebuild: (prev, next) =>
          prev.upcoming.length != next.upcoming.length ||
          prev.ipoIsLive != next.ipoIsLive,
      builder: (ctx, data, __) {
        if (data.upcoming.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader('Upcoming IPOs', isLive: data.ipoIsLive),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: data.upcoming.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _UpcomingTile(ipo: data.upcoming[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Top Gainers section ---
class _TopGainersSection extends StatelessWidget {
  const _TopGainersSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<StockQuote> gainers, bool isLive, bool hasSnap})>(
      selector: (_, s) => (
        gainers: s.snapshot?.gainers ?? const [],
        isLive: s.snapshot?.isLive ?? false,
        hasSnap: s.snapshot != null,
      ),
      shouldRebuild: (prev, next) =>
          prev.hasSnap != next.hasSnap ||
          prev.isLive != next.isLive ||
          prev.gainers.length != next.gainers.length ||
          (prev.gainers.isNotEmpty &&
              next.gainers.isNotEmpty &&
              prev.gainers[0].changePct != next.gainers[0].changePct),
      builder: (ctx, data, __) {
        if (!data.hasSnap) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'NSE Top Gainers',
              action: 'More',
              onAction: () => ctx.findAncestorStateOfType<_HomeShellState>()?.switchTab(2),
              isLive: data.isLive,
            ),
            ...data.gainers.take(10).map((q) => StockTile(quote: q)),
          ],
        );
      },
    );
  }
}

// --- Top Losers section ---
class _TopLosersSection extends StatelessWidget {
  const _TopLosersSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<StockQuote> losers, bool isLive, bool hasSnap})>(
      selector: (_, s) => (
        losers: s.snapshot?.losers ?? const [],
        isLive: s.snapshot?.isLive ?? false,
        hasSnap: s.snapshot != null,
      ),
      shouldRebuild: (prev, next) =>
          prev.hasSnap != next.hasSnap ||
          prev.isLive != next.isLive ||
          prev.losers.length != next.losers.length ||
          (prev.losers.isNotEmpty &&
              next.losers.isNotEmpty &&
              prev.losers[0].changePct != next.losers[0].changePct),
      builder: (ctx, data, __) {
        if (!data.hasSnap) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'NSE Top Losers',
              action: 'More',
              onAction: () => ctx.findAncestorStateOfType<_HomeShellState>()?.switchTab(2),
              isLive: data.isLive,
            ),
            ...data.losers.take(10).map((q) => StockTile(quote: q)),
          ],
        );
      },
    );
  }
}

// --- Latest News section ---
class _LatestNewsSection extends StatelessWidget {
  const _LatestNewsSection();
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, ({List<NewsArticle> news, bool newsIsLive})>(
      selector: (_, s) => (news: s.news, newsIsLive: s.newsIsLive),
      shouldRebuild: (prev, next) =>
          prev.newsIsLive != next.newsIsLive ||
          prev.news.length != next.news.length ||
          (prev.news.isNotEmpty &&
              next.news.isNotEmpty &&
              prev.news[0].title != next.news[0].title),
      builder: (ctx, data, __) {
        if (data.news.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              'Latest News',
              action: 'More',
              onAction: () => ctx.findAncestorStateOfType<_HomeShellState>()?.switchTab(4),
              isLive: data.newsIsLive,
            ),
            ...data.news.take(4).map((a) => NewsTile(article: a, compact: true)),
          ],
        );
      },
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();
  @override
  Widget build(BuildContext context) => const Column(
        children: [
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Market data may be delayed. Nothing here is SEBI-registered investment advice.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
}

class _IndexStrip extends StatelessWidget {
  const _IndexStrip({
    required this.indices,
    required this.loading,
    required this.isLive,
  });
  final List<MarketIndex> indices;
  final bool loading;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
      if (loading) {
        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => const ShimmerBox(width: 152, height: 92, borderRadius: 10),
          ),
        );
      }
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Market data unavailable')),
      );
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        itemCount: indices.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _LiveIndexCard(
          index: indices[i],
          isLive: isLive,
        ),
      ),
    );
  }
}

class _LiveIndexCard extends StatefulWidget {
  const _LiveIndexCard({required this.index, required this.isLive});
  final MarketIndex index;
  final bool isLive;

  @override
  State<_LiveIndexCard> createState() => _LiveIndexCardState();
}

class _LiveIndexCardState extends State<_LiveIndexCard> {
  Color? _flashBorderColor;

  @override
  void didUpdateWidget(covariant _LiveIndexCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index.last != widget.index.last) {
      final isUp = widget.index.last > oldWidget.index.last;
      setState(() {
        _flashBorderColor = isUp
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {
            _flashBorderColor = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idx = widget.index;
    final c = gainColor(context, idx.isUp);

    final defaultBorder = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final borderColor = _flashBorderColor ?? defaultBorder;
    final cardBg = _flashBorderColor != null
        ? _flashBorderColor!.withValues(alpha: isDark ? 0.2 : 0.1)
        : (isDark ? const Color(0xFF111827) : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 152,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: _flashBorderColor != null ? 1.5 : 1.0,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(idx.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          Text(idx.exchange,
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
          const SizedBox(width: 4),
          LiveDot(isLive: widget.isLive),
        ]),
        const SizedBox(height: 2),
        Text(num2.format(idx.last),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        Text(
          '${idx.isUp ? '+' : ''}${num2.format(idx.change)} (${idx.isUp ? '+' : ''}${idx.changePct.toStringAsFixed(2)}%)',
          style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11),
        ),
        if (idx.sparkline.isNotEmpty)
          Expanded(child: Sparkline(idx.sparkline, up: idx.isUp, height: 20)),
      ]),
    );
  }
}

class _AiBriefCard extends StatelessWidget {
  const _AiBriefCard();

  @override
  Widget build(BuildContext context) {
    return Selector<AppState,
        ({String? brief, bool briefLoading, Sentiment mood, bool isCfg, bool canGen})>(
      selector: (_, s) => (
        brief: s.brief,
        briefLoading: s.briefLoading,
        mood: s.marketMood,
        isCfg: s.ai.isConfigured,
        canGen: s.indices.isNotEmpty || s.news.isNotEmpty,
      ),
      shouldRebuild: (prev, next) =>
          prev.brief != next.brief ||
          prev.briefLoading != next.briefLoading ||
          prev.mood.label != next.mood.label ||
          prev.isCfg != next.isCfg ||
          prev.canGen != next.canGen,
      builder: (ctx, data, __) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: .15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 6),
              const Text(
                'SpotAI Market Brief',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
              ),
              const Spacer(),
              SentimentChip(data.mood, compact: true),
            ]),
            const SizedBox(height: 6),
            if (data.brief != null)
              Text(data.brief!, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3))
            else if (data.briefLoading)
              const LinearProgressIndicator()
            else
              Row(children: [
                Expanded(
                  child: Text(
                    data.isCfg
                        ? 'Generate a live AI summary of today\'s market.'
                        : 'Get an on-device market summary.',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 30,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: data.canGen ? ctx.read<AppState>().loadBrief : null,
                    child: const Text('Generate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
          ]),
        );
      },
    );
  }
}


class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.ipo});
  final Ipo ipo;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => openIpo(context, ipo),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(ipo.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              if (ipo.isSme)
                const Padding(padding: EdgeInsets.only(left: 4), child: Chip(label: Text('SME', style: TextStyle(fontSize: 10)), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact)),
            ]),
            const Spacer(),
            Text('Opens ${ipo.openDate != null ? dateFmt.format(ipo.openDate!) : 'TBA'} · Closes ${ipo.closeDate != null ? dateFmt.format(ipo.closeDate!) : 'TBA'}',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 4),
            Text(ipo.priceMin > 0 ? "${inr.format(ipo.priceMin)} – ${inr.format(ipo.priceMax)}" : "TBA",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Lot ${ipo.lotSize ?? "—"} · ${ipo.issueSizeCr > 0 ? "${inr.format(ipo.issueSizeCr)} Cr" : "—"}', style: const TextStyle(fontSize: 11)),
          ]),
        ),
      );
}
