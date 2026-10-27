import 'dart:ui';
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

/// Floating Liquid Glass Navigation Bar inspired by the Liquid Glass Kit aesthetic.
/// Features true glassmorphic blur, specular rim reflection, glowing liquid active pill,
/// and smooth sliding transitions.
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
      duration: const Duration(milliseconds: 320),
    );
    _animation = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
        curve: Curves.easeOutBack,
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
    const barHeight = 66.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final count = widget.items.length;
            final itemWidth = totalWidth / count;
            final activePillWidth = itemWidth - 6;

            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final animValue = _animation.value;
                final pillLeft = (animValue * itemWidth) + 3;

                return Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      // Ambient deep shadow floating above content
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.50),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                      // Soft emerald ambient aura
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.10),
                        blurRadius: 20,
                        spreadRadius: -2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Stack(
                        children: [
                          // 1. Liquid Glass Translucent Base with Specular Border
                          CustomPaint(
                            size: Size(totalWidth, barHeight),
                            painter: const _LiquidGlassBorderPainter(),
                          ),

                          // 2. Liquid Gloss Sheen along the top curve (Physical light reflection)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 28,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.30),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 3. Sliding Liquid Emerald Active Indicator Pill
                          Positioned(
                            left: pillLeft,
                            top: 6,
                            bottom: 6,
                            width: activePillWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF34D399), // Mint green
                                    Color(0xFF10B981), // Emerald green
                                    Color(0xFF059669), // Forest green
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.45),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              // Inner liquid gloss on the active pill
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 14,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.45),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 4. Navigation Tab Items (Icons + Labels)
                          Row(
                            children: List.generate(count, (index) {
                              final item = widget.items[index];
                              final isSelected = index == widget.selectedIndex;

                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => widget.onTap(index),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isSelected ? item.selectedIcon : item.icon,
                                          color: isSelected
                                              ? const Color(0xFF042013) // Dark contrast on active emerald pill
                                              : Colors.white.withValues(alpha: 0.68),
                                          size: isSelected ? 21 : 20,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF042013)
                                                : Colors.white.withValues(alpha: 0.65),
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
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

// ==============================================================================
// Specular Refraction Border Painter for Liquid Glass Kit Aesthetic
// ==============================================================================
class _LiquidGlassBorderPainter extends CustomPainter {
  const _LiquidGlassBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 34.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    // 1. Semi-translucent glass fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.03),
          const Color(0xFF081810).withValues(alpha: 0.40),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fillPaint);

    // 2. Specular glass refraction border (Brighter on top-left, subtle on bottom-right)
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.45), // Specular gleam at top-left
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.06), // Darker edge at bottom-right
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
