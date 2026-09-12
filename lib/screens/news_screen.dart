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
    final s = context.watch<AppState>();
    final items = s.news.where((a) {
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
          LiveBadge(live: s.newsIsLive),
        ]),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: s.loadNews)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search BSE, NSE, IPO, stocks…',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(_categories[i]),
                  selected: _category == _categories[i],
                  onSelected: (_) => setState(() => _category = _categories[i]),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ]),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: s.loadNews,
        child: s.newsLoading && s.news.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 120),
                    EmptyState(icon: Icons.newspaper, title: 'No news matches your filter'),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 96),
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
  }
}

class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.article, this.compact = false});
  final NewsArticle article;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sentiment = AiService.sentimentOf('${article.title} ${article.description ?? ''}');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          AdService.instance.recordDetailView();
          launchUrl(Uri.parse(article.link), mode: LaunchMode.inAppBrowserView);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (article.imageUrl != null && !compact)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(article.category,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                  ),
                  const SizedBox(width: 6),
                  SentimentChip(sentiment, compact: true),
                  const Spacer(),
                  Text(timeAgo(article.publishedAt), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
                ]),
                const SizedBox(height: 6),
                Text(article.title,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
                if (!compact && article.description != null) ...[
                  const SizedBox(height: 4),
                  Text(article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                ],
                const SizedBox(height: 4),
                Text(article.source, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
