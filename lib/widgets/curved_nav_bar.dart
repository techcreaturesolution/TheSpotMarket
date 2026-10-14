import 'package:flutter/material.dart';

class NavItemData {
  const NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class CurvedNotchedNavBar extends StatefulWidget {
  const CurvedNotchedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  @override
  State<CurvedNotchedNavBar> createState() => _CurvedNotchedNavBarState();
}

class _CurvedNotchedNavBarState extends State<CurvedNotchedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _targetIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(CurvedNotchedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _targetIndex) {
      _targetIndex = widget.selectedIndex;
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.selectedIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme color palette matching the app's current green theme
    final navBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final activeCircleColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    final shadowColor = (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: .25);
    final inactiveIconColor = Colors.white.withValues(alpha: .6);

    const barHeight = 64.0;
    const circleSize = 52.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final count = widget.items.length;
            final itemWidth = totalWidth / count;

            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final animValue = _animation.value;
                final circleLeft = (animValue * itemWidth) + (itemWidth - circleSize) / 2;

                return SizedBox(
                  height: barHeight + 14,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Main Curved Notched Container
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: barHeight,
                      child: CustomPaint(
                        painter: _NotchedBarPainter(
                          progress: animValue,
                          itemCount: count,
                          color: navBgColor,
                          shadowColor: shadowColor,
                        ),
                      ),
                    ),

                    // Inactive Icons & Tap targets
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: barHeight,
                      child: Row(
                        children: List.generate(count, (index) {
                          final item = widget.items[index];
                          final isSelected = index == widget.selectedIndex;

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTap(index),
                              child: Container(
                                alignment: Alignment.center,
                                child: Opacity(
                                  opacity: isSelected ? 0.0 : 1.0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        color: inactiveIconColor,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          color: inactiveIconColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Floating Active Circle Icon Badge
                    Positioned(
                      left: circleLeft,
                      bottom: barHeight - (circleSize / 2) - 4,
                      child: GestureDetector(
                        onTap: () => widget.onTap(widget.selectedIndex),
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeCircleColor,
                            boxShadow: [
                              BoxShadow(
                                color: activeCircleColor.withValues(alpha: .4),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.items[widget.selectedIndex].selectedIcon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter({
    required this.progress,
    required this.itemCount,
    required this.color,
    required this.shadowColor,
  });

  final double progress;
  final int itemCount;
  final Color color;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final itemWidth = size.width / itemCount;
    final centerX = (progress * itemWidth) + (itemWidth / 2);

    const radius = 24.0;
    const notchRadius = 36.0;
    const notchDepth = 24.0;

    final path = Path();
    path.moveTo(radius, 0);

    final notchLeft = (centerX - notchRadius).clamp(radius, size.width - radius);
    final notchRight = (centerX + notchRadius).clamp(radius, size.width - radius);

    path.lineTo(notchLeft, 0);

    path.cubicTo(
      notchLeft + 10, 0,
      centerX - 18, notchDepth,
      centerX, notchDepth,
    );
    path.cubicTo(
      centerX + 18, notchDepth,
      notchRight - 10, 0,
      notchRight, 0,
    );

    path.lineTo(size.width - radius, 0);

    path.quadraticBezierTo(size.width, 0, size.width, radius);

    path.lineTo(size.width, size.height - radius);

    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    path.lineTo(radius, size.height);

    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.lineTo(0, radius);

    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();

    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.itemCount != itemCount;
}
