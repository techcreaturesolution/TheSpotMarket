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

String priceFmt(StockQuote q) => money(q.currency, q.lastPrice);

String money(String currency, double v) =>
    currency == '₹' ? inr2.format(v) : '$currency${num2.format(v)}';

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return dateFmt.format(t);
}

Color gainColor(BuildContext context, bool up) =>
    up ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
      child: SizedBox(
        height: 360,
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class LiveDot extends StatelessWidget {
  const LiveDot({super.key, required this.isLive, this.showLabel = false, this.label});
  final bool isLive;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final textLabel = label ?? (isLive ? 'LIVE' : 'DEMO DATA');
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: showLabel ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              textLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.isLive});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final bool? isLive;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Row(
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (isLive != null) ...[
              const SizedBox(width: 8),
              LiveDot(isLive: isLive!, showLabel: true),
            ],
            const Spacer(),
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
  Widget build(BuildContext context) => LiveDot(isLive: live, showLabel: true);
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
  const Sparkline(this.points, {super.key, required this.up, this.height = 36, this.showEndDot = true});
  final List<double> points;
  final bool up;
  final double height;
  final bool showEndDot;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: height);
    final color = gainColor(context, up);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final delta = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: minVal - delta * 0.15,
          maxY: maxVal + delta * 0.15,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i])
              ],
              isCurved: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: showEndDot,
                checkToShowDot: (spot, barData) => spot.x == barData.spots.last.x,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: .35),
                    color.withValues(alpha: .0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium chart card widget matching Image 3 design (without top-right timeframe pills).
class DetailedChartCard extends StatelessWidget {
  const DetailedChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.changePct,
    required this.points,
    this.currency = '',
    this.change,
    this.labels = const ['AUG 1', 'AUG 6', 'AUG 12'],
    this.stats = const [],
    this.onViewDetails,
  });

  final String title;
  final String subtitle;
  final String value;
  final double changePct;
  final double? change;
  final String currency;
  final List<double> points;
  final List<String> labels;
  final List<(String, String)> stats;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final isUp = changePct >= 0;
    final color = gainColor(context, isUp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final minVal = points.isEmpty
        ? 0.0
        : points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.isEmpty
        ? 100.0
        : points.reduce((a, b) => a > b ? a : b);
    final delta = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$currency$value',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 10,
                          color: color,
                        ),
                        const SizedBox(width: 1),
                        Text(
                          '${changePct.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (points.isNotEmpty) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                RepaintBoundary(
                  child: SizedBox(
                    height: 42,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: delta / 2,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: (isDark ? Colors.white10 : Colors.black12),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: const LineTouchData(enabled: false),
                        minY: minVal - delta * 0.15,
                        maxY: maxVal + delta * 0.15,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < points.length; i++)
                                FlSpot(i.toDouble(), points[i])
                            ],
                            isCurved: true,
                            color: color,
                            barWidth: 1.8,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) =>
                                  spot.x == barData.spots.last.x,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 3,
                                color: color,
                                strokeWidth: 1.5,
                                strokeColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                                colors: [
                                  color.withValues(alpha: 0.25),
                                  color.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 6),
            Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 6),
            Column(
              children: [
                for (var i = 0; i < stats.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                stats[i].$1,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                stats[i].$2,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i + 1 < stats.length) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stats[i + 1].$1,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  stats[i + 1].$2,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (onViewDetails != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewDetails,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ActionChipLabel extends StatelessWidget {
  const ActionChipLabel(this.action, {super.key});
  final TradeAction action;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: action.color.withValues(alpha: .5)),
        ),
        child: Text(action.label,
            style: TextStyle(color: action.color, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: .5)),
      );
}

/// Card for one buy / sell / hold idea with target, stop-loss and reasons.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key, required this.s});
  final StockSuggestion s;

  @override
  Widget build(BuildContext context) {
    final q = s.quote;
    final c = gainColor(context, q.isUp);
    final outline = Theme.of(context).colorScheme.outline;
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ActionChipLabel(s.action),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(q.symbol, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(q.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: outline)),
              ]),
            ),
            if (q.sparkline.isNotEmpty) ...[
              SizedBox(width: 64, child: Sparkline(q.sparkline, up: q.isUp, height: 26)),
              const SizedBox(width: 8),
            ],
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(priceFmt(q), style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${q.isUp ? '+' : ''}${q.changePct.toStringAsFixed(2)}%',
                  style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _Stat('Target', money(q.currency, s.target), Colors.green),
            _Stat('Stop loss', money(q.currency, s.stopLoss), Colors.red),
            _Stat('Confidence', '${s.confidence}%', s.action.color),
          ]),
          const SizedBox(height: 8),
          ...s.reasons.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.circle, size: 6, color: outline),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
                ]),
              )),
          const SizedBox(height: 4),
          Text(s.horizon, style: TextStyle(fontSize: 11, color: outline)),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
        ]),
      );
}

class SuggestionDisclaimer extends StatelessWidget {
  const SuggestionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text(
          'Ideas are generated by SpotAI from price momentum, news sentiment and market mood. '
          'Educational only – not SEBI-registered investment advice. Do your own research before trading.',
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
        ),
      );
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

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final color = Color.lerp(baseColor, highlightColor, _ctrl.value);
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class IpoCardSkeleton extends StatelessWidget {
  const IpoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 16, borderRadius: 4)),
                SizedBox(width: 40),
                ShimmerBox(width: 55, height: 20, borderRadius: 10),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ShimmerBox(width: 90, height: 12, borderRadius: 3),
                SizedBox(width: 12),
                ShimmerBox(width: 70, height: 12, borderRadius: 3),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120, height: 14, borderRadius: 4),
                ShimmerBox(width: 60, height: 14, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StockTileSkeleton extends StatelessWidget {
  const StockTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 110, height: 14, borderRadius: 4),
                SizedBox(height: 4),
                ShimmerBox(width: 160, height: 10, borderRadius: 3),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 60, height: 14, borderRadius: 4),
              SizedBox(height: 4),
              ShimmerBox(width: 45, height: 12, borderRadius: 3),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsTileSkeleton extends StatelessWidget {
  const NewsTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 180, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerBox(width: 50, height: 10, borderRadius: 3),
                    SizedBox(width: 10),
                    ShimmerBox(width: 60, height: 10, borderRadius: 3),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 68, height: 68, borderRadius: 8),
        ],
      ),
    );
  }
}

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
              Text(
                'Fetching live market updates & IPOs…',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => const ShimmerBox(width: 152, height: 92, borderRadius: 10),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: ShimmerBox(width: double.infinity, height: 68, borderRadius: 10),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ShimmerBox(width: 130, height: 18, borderRadius: 4),
        ),
        const IpoCardSkeleton(),
        const IpoCardSkeleton(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ShimmerBox(width: 150, height: 18, borderRadius: 4),
        ),
        const StockTileSkeleton(),
        const StockTileSkeleton(),
        const StockTileSkeleton(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ShimmerBox(width: 120, height: 18, borderRadius: 4),
        ),
        const NewsTileSkeleton(),
        const NewsTileSkeleton(),
      ],
    );
  }
}
