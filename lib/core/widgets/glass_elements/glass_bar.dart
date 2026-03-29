import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;
  final int? selectedIndex;
  final int? itemCount;
  final double pillInset;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 32,
    this.width,
    this.height,
    this.shadows,
    this.selectedIndex,
    this.itemCount,
    this.pillInset = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _GlassFill(
          borderRadius: borderRadius,
          child: _maybeWithPill(child),
        ),
      ),
    );
  }

  Widget _maybeWithPill(Widget child) {
    if (selectedIndex == null || itemCount == null || width == null) {
      return child;
    }

    final pillWidth = (width! - pillInset * 2) / itemCount!;
    final flippedIndex = itemCount! - 1 - selectedIndex!;
    final pillLeft = pillInset + flippedIndex * pillWidth;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          top: pillInset,
          bottom: pillInset,
          left: pillLeft,
          width: pillWidth,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius - pillInset),
              color: Colors.white.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlassFill extends StatelessWidget {
  final double borderRadius;
  final Widget child;

  const _GlassFill({
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.62),
          ),
        ),
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
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _GlassRimPainter(
              borderRadius: borderRadius,
              topColor: Colors.white.withOpacity(0.80),
              bottomColor: Colors.white.withOpacity(0.20),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  final double borderRadius;
  final Color topColor;
  final Color bottomColor;

  const _GlassRimPainter({
    required this.borderRadius,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(borderRadius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) =>
      old.topColor != topColor ||
      old.bottomColor != bottomColor ||
      old.borderRadius != borderRadius;
}
