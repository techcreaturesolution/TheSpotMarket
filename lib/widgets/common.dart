import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/ad_service.dart';
import '../services/ai_service.dart';

final inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final inr2 = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final num2 = NumberFormat('#,##0.00', 'en_IN');
final dateFmt = DateFormat('d MMM');
final dateFullFmt = DateFormat('d MMM yyyy');

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return dateFmt.format(t);
}

Color gainColor(BuildContext context, bool up) =>
    up ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

/// Adaptive banner that collapses to zero height until the ad loads or when
/// ads are unsupported (web / desktop / tests).
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.size = AdSize.banner});
  final AdSize size;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdService.instance.isSupported) return;
    _ad = AdService.instance.createBanner(
      size: widget.size,
      onLoaded: () => mounted ? setState(() => _loaded = true) : null,
      onFailed: () => mounted ? setState(() => _ad = null) : null,
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.center,
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

/// Native ad card for injection into list views.
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdService.instance.isSupported) return;
    _ad = AdService.instance.createNative(
      onLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
      onFailed: () => mounted ? setState(() => _ad = null) : null,
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 320, maxHeight: 360),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (action != null)
              TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ),
      );
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, required this.live});
  final bool live;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: (live ? Colors.green : Colors.orange).withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 8, color: live ? Colors.green : Colors.orange),
          const SizedBox(width: 4),
          Text(live ? 'LIVE' : 'SAMPLE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: live ? Colors.green.shade800 : Colors.orange.shade800)),
        ]),
      );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final IpoStatus status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status.label,
            style: TextStyle(
                color: status.color, fontWeight: FontWeight.w700, fontSize: 12)),
      );
}

class SentimentChip extends StatelessWidget {
  const SentimentChip(this.sentiment, {super.key, this.compact = false});
  final Sentiment sentiment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (sentiment.label) {
      'Bullish' => const Color(0xFF16A34A),
      'Bearish' => const Color(0xFFDC2626),
      _ => Colors.grey,
    };
    final icon = switch (sentiment.label) {
      'Bullish' => Icons.trending_up,
      'Bearish' => Icons.trending_down,
      _ => Icons.trending_flat,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: compact ? 12 : 16, color: color),
        const SizedBox(width: 4),
        Text(sentiment.label,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11 : 13)),
      ]),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline(this.points, {super.key, required this.up, this.height = 36});
  final List<double> points;
  final bool up;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: height);
    final color = gainColor(context, up);
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: points.reduce((a, b) => a < b ? a : b),
          maxY: points.reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i])
              ],
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: .3), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {super.key, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.outline))),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: valueColor)),
        ]),
      );
}
