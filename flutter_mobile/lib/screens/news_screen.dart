import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/ad_service.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const _categories = ['All', 'IPO', 'Stocks', 'Indices', 'NSE', 'BSE', 'Economy', 'Business'];
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Only rebuild when news data or live status changes — NOT every market tick.
    return Selector<AppState, ({List<NewsArticle> news, bool newsIsLive, bool newsLoading})>(
      selector: (_, s) => (
        news: s.news,
        newsIsLive: s.newsIsLive,
        newsLoading: s.newsLoading,
      ),
      shouldRebuild: (prev, next) =>
          prev.newsIsLive != next.newsIsLive ||
          prev.newsLoading != next.newsLoading ||
          prev.news.length != next.news.length ||
          (prev.news.isNotEmpty &&
              next.news.isNotEmpty &&
              prev.news[0].title != next.news[0].title),
      builder: (ctx, data, __) {
        final items = data.news.where((a) {
          final catOk = _category == 'All' || a.category == _category;
          final q = _query.toLowerCase();
          final qOk = q.isEmpty || a.title.toLowerCase().contains(q) || (a.description?.toLowerCase().contains(q) ?? false);
          return catOk && qOk;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              const Text('Market News'),
              const SizedBox(width: 8),
              LiveBadge(live: data.newsIsLive),
            ]),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: ctx.read<AppState>().loadNews)],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search BSE, NSE, IPO, stocks…',
                        hintStyle: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.45)),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF34D399)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isSel = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isSel
                                ? const LinearGradient(
                                    colors: [Color(0xFF34D399), Color(0xFF10B981)],
                                  )
                                : null,
                            color: isSel ? null : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isSel ? const Color(0xFF34D399) : Colors.white.withValues(alpha: 0.10),
                              width: 1,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? const Color(0xFF042013) : Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
              ]),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: ctx.read<AppState>().loadNews,
            child: (data.newsLoading && data.news.isEmpty)
                ? ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 96),
                    children: const [
                      NewsTileSkeleton(),
                      NewsTileSkeleton(),
                      NewsTileSkeleton(),
                      NewsTileSkeleton(),
                    ],
                  )
                : items.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 120),
                        EmptyState(icon: Icons.newspaper, title: 'No news matches your filter'),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 96),
                        itemCount: items.length + items.length ~/ 6,
                        itemBuilder: (_, i) {
                          // native ad after every 6 articles
                          if (i > 0 && i % 7 == 6) return const NativeAdCard();
                          final idx = i - i ~/ 7;
                          return NewsTile(article: items[idx]);
                        },
                      ),
          ),
        );
      },
    );
  }
}

class NewsTile extends StatefulWidget {
  const NewsTile({super.key, required this.article, this.compact = false});
  final NewsArticle article;
  final bool compact;

  @override
  State<NewsTile> createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile> {
  // Cache the sentiment so AiService.sentimentOf() isn't called on every rebuild.
  late Sentiment _sentiment;

  @override
  void initState() {
    super.initState();
    _sentiment = AiService.sentimentOf('${widget.article.title} ${widget.article.description ?? ''}');
  }

  @override
  void didUpdateWidget(covariant NewsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.title != widget.article.title) {
      _sentiment = AiService.sentimentOf('${widget.article.title} ${widget.article.description ?? ''}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.08 : 0.7),
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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AdService.instance.recordDetailView();
            launchUrl(Uri.parse(widget.article.link), mode: LaunchMode.inAppBrowserView);
          },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    if (widget.article.imageUrl != null && !widget.compact)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: widget.article.imageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .3), width: 0.8),
                            ),
                            child: Text(
                              widget.article.category,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          SentimentChip(_sentiment, compact: true),
                          const Spacer(),
                          Text(
                            timeAgo(widget.article.publishedAt),
                            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
                          ),
                        ]),
                        const SizedBox(height: 5),
                        Text(
                          widget.article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.article.source,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          );
  }
}
