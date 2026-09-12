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
import 'ipo_screens.dart';
import 'market_screen.dart';
import 'news_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void switchTab(int i) => setState(() => _index = i);

  static const _tabs = [
    DashboardScreen(),
    IpoListScreen(),
    MarketScreen(),
    NewsScreen(),
    AllotmentScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAll();
    });
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
        bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
          const BannerAdWidget(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), selectedIcon: Icon(Icons.rocket_launch), label: 'IPOs'),
              NavigationDestination(icon: Icon(Icons.show_chart), label: 'Market'),
              NavigationDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper), label: 'News'),
              NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Allotment'),
            ],
          ),
        ]),
      );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final open = s.iposWhere(IpoStatus.open);
    final upcoming = s.iposWhere(IpoStatus.upcoming);
    final mood = s.marketMood;

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
      body: RefreshIndicator(
        onRefresh: s.refreshAll,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _IndexStrip(indices: s.indices, loading: s.marketLoading),
            _AiBriefCard(mood: mood),
            SectionHeader('Open IPOs (${open.length})',
                action: 'See all', onAction: () => _goto(context, 1)),
            if (s.ipoLoading && s.ipos.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (open.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No IPO is open for subscription right now.'),
              )
            else
              ...open.take(3).map((i) => IpoCard(ipo: i)),
            if (upcoming.isNotEmpty) ...[
              SectionHeader('Upcoming IPOs'),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: upcoming.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _UpcomingTile(ipo: upcoming[i]),
                ),
              ),
            ],
            if (s.snapshot != null) ...[
              SectionHeader('Top Gainers', action: 'Market', onAction: () => _goto(context, 2)),
              ...s.snapshot!.gainers.take(3).map((q) => StockTile(quote: q)),
              SectionHeader('Top Losers'),
              ...s.snapshot!.losers.take(3).map((q) => StockTile(quote: q)),
            ],
            SectionHeader('Latest News', action: 'More', onAction: () => _goto(context, 3)),
            ...s.news.take(4).map((a) => NewsTile(article: a, compact: true)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Market data may be delayed. Nothing here is SEBI-registered investment advice.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goto(BuildContext context, int tab) {
    context.findAncestorStateOfType<_HomeShellState>()?.switchTab(tab);
  }
}

class _IndexStrip extends StatelessWidget {
  const _IndexStrip({required this.indices, required this.loading});
  final List<MarketIndex> indices;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(child: loading ? const CircularProgressIndicator() : const Text('Market data unavailable')),
      );
    }
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        itemCount: indices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final idx = indices[i];
          final c = gainColor(context, idx.isUp);
          return Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(idx.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                Text(idx.exchange, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline)),
              ]),
              const SizedBox(height: 4),
              Text(num2.format(idx.last), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(
                '${idx.isUp ? '+' : ''}${num2.format(idx.change)} (${idx.isUp ? '+' : ''}${idx.changePct.toStringAsFixed(2)}%)',
                style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12),
              ),
              if (idx.sparkline.isNotEmpty)
                Expanded(child: Sparkline(idx.sparkline, up: idx.isUp, height: 24)),
            ]),
          );
        },
      ),
    );
  }
}

class _AiBriefCard extends StatefulWidget {
  const _AiBriefCard({required this.mood});
  final Sentiment mood;

  @override
  State<_AiBriefCard> createState() => _AiBriefCardState();
}

class _AiBriefCardState extends State<_AiBriefCard> {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: scheme.onPrimaryContainer, size: 18),
            const SizedBox(width: 6),
            Text('SpotAI Market Brief',
                style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer)),
            const Spacer(),
            SentimentChip(s.marketMood, compact: true),
          ]),
          const SizedBox(height: 8),
          if (s.brief != null)
            Text(s.brief!, style: TextStyle(color: scheme.onPrimaryContainer, height: 1.35))
          else if (s.briefLoading)
            const LinearProgressIndicator()
          else
            Row(children: [
              Expanded(
                child: Text(
                  s.ai.isConfigured
                      ? 'Generate a live AI summary of today\'s market.'
                      : 'Get an on-device market summary (add an AI key in Settings for a richer brief).',
                  style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13),
                ),
              ),
              FilledButton.tonal(
                onPressed: s.indices.isEmpty && s.news.isEmpty ? null : s.loadBrief,
                child: const Text('Generate'),
              ),
            ]),
        ]),
      ),
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
            Text('Opens ${dateFmt.format(ipo.openDate)} · Closes ${dateFmt.format(ipo.closeDate)}',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 4),
            Text('${inr.format(ipo.priceMin)} – ${inr.format(ipo.priceMax)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Lot ${ipo.lotSize} · ${inr.format(ipo.issueSizeCr)} Cr', style: const TextStyle(fontSize: 11)),
          ]),
        ),
      );
}
