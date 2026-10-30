import 'dart:ui';
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
        body: IndexedStack(
          index: _index,
          children: _tabs.map((tab) => RepaintBoundary(child: tab)).toList(),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: RepaintBoundary(
            child: _LiquidGlassFab(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatScreen()),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BannerAdWidget(),
            RepaintBoundary(
              child: CurvedNotchedNavBar(
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
      backgroundColor: const Color(0xFF040A07),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: const Color(0xFF040A07).withValues(alpha: 0.72),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            const Text(
              AppConfig.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.9),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Builder(builder: (context) {
            final auth = context.watch<AuthService>();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => auth.isSignedIn ? const SettingsScreen() : const AuthScreen(),
                  ),
                ),

                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: auth.isSignedIn
                        ? Text(
                            auth.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          )
                        : const Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Liquid Blooms
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 320,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: context.read<AppState>().refreshAll,
            child: (isInitialLoading && !hasData)
                ? const DashboardLoadingSkeleton()
                : const _DashboardBody(),
          ),
        ],
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
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight + 6;
    return ListView(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 96),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  'No IPO is open for subscription right now.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.60),
                  ),
                ),
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
        _flashBorderColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
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
    final idx = widget.index;
    final c = gainColor(context, idx.isUp);
    final borderColor = _flashBorderColor ?? Colors.white.withValues(alpha: 0.14);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
          width: 158,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _flashBorderColor != null
                    ? _flashBorderColor!.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.09),
                const Color(0xFF0C2016).withValues(alpha: 0.45),
                const Color(0xFF030D08).withValues(alpha: 0.70),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: borderColor,
              width: _flashBorderColor != null ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      idx.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
                    ),
                    child: Text(
                      idx.exchange,
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  LiveDot(isLive: widget.isLive),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                num2.format(idx.last),
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
              ),
              Text(
                '${idx.isUp ? '+' : ''}${num2.format(idx.change)} (${idx.isUp ? '+' : ''}${idx.changePct.toStringAsFixed(2)}%)',
                style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11),
              ),
              if (idx.sparkline.isNotEmpty)
                Expanded(child: Sparkline(idx.sparkline, up: idx.isUp, height: 20)),
            ],
          ),
        ),
      ),
    ),
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
        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.14),
                      const Color(0xFF092216).withValues(alpha: 0.40),
                      const Color(0xFF03140C).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.32),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF10B981).withValues(alpha: 0.20),
                            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.45), width: 1),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF34D399), size: 14),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SpotAI Market Brief',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
                        ),
                        const Spacer(),
                        SentimentChip(data.mood, compact: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (data.brief != null)
                      Text(data.brief!, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35))
                    else if (data.briefLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white12,
                          color: Color(0xFF10B981),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.isCfg
                                  ? 'Generate a live AI summary of today\'s market.'
                                  : 'Get an on-device market summary.',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.70), fontSize: 11.5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: data.canGen ? ctx.read<AppState>().loadBrief : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF34D399),
                                    Color(0xFF10B981),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Generate',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF042013),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.ipo});
  final Ipo ipo;

  @override
  Widget build(BuildContext context) => Container(
        width: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.09),
              const Color(0xFF0C2016).withValues(alpha: 0.40),
              const Color(0xFF030D08).withValues(alpha: 0.70),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openIpo(context, ipo),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ipo.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                        ),
                      ),
                      if (ipo.isSme)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: const Text('SME', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF34D399))),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Opens ${ipo.openDate != null ? dateFmt.format(ipo.openDate!) : 'TBA'} · Closes ${ipo.closeDate != null ? dateFmt.format(ipo.closeDate!) : 'TBA'}',
                    style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.55)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ipo.priceMin > 0 ? "${inr.format(ipo.priceMin)} – ${inr.format(ipo.priceMax)}" : "TBA",
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                  ),
                  Text(
                    'Lot ${ipo.lotSize ?? "—"} · ${ipo.issueSizeCr > 0 ? "${inr.format(ipo.issueSizeCr)} Cr" : "—"}',
                    style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.65)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ==============================================================================
// Liquid Glass Floating Action Button (SpotAI)
// ==============================================================================
class _LiquidGlassFab extends StatelessWidget {
  const _LiquidGlassFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6EE7B7), // Mint green highlight
            Color(0xFF10B981), // Core Emerald
            Color(0xFF059669), // Rich green base
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF032213), size: 16.5),
                SizedBox(width: 6.5),
                Text(
                  'SpotAI',
                  style: TextStyle(
                    color: Color(0xFF032213),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

