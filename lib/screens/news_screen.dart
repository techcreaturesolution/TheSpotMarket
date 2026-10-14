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
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search BSE, NSE, IPO, stocks…',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        isDense: true,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => ChoiceChip(
                      label: Text(_categories[i], style: const TextStyle(fontSize: 11)),
                      selected: _category == _categories[i],
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => setState(() => _category = _categories[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          AdService.instance.recordDetailView();
          launchUrl(Uri.parse(widget.article.link), mode: LaunchMode.inAppBrowserView);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (widget.article.imageUrl != null && !widget.compact)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.article.category,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SentimentChip(_sentiment, compact: true),
                  const Spacer(),
                  Text(
                    timeAgo(widget.article.publishedAt),
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(
                  widget.article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.article.source,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.outline),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
