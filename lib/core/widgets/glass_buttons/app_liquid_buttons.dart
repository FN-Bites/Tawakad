import 'dart:ui';
import 'package:flutter/material.dart';

class AppLiquidButtons {
  AppLiquidButtons._();

  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      _LiquidButton(label: label, onPressed: onPressed, isPrimary: true);

  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      _LiquidButton(label: label, onPressed: onPressed, isPrimary: false);

  static Widget small({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      _SmallGlassButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ));

  /// Small frosted glass button with an icon (e.g. arrow, back, etc.).
  /// Fixed 44×44 square — same height as [small].
  static Widget icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color iconColor = const Color(0xFF1C1C1E),
    double iconSize = 18,
  }) =>
      _SmallGlassButton(
        onPressed: onPressed,
        isSquare: true,
        child: Icon(icon, color: iconColor, size: iconSize),
      );
}

// ─── FULL-WIDTH BUTTON (PRIMARY + SECONDARY) ──────────────────────────────────

class _LiquidButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _LiquidButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<_LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: widget.isPrimary
            ? _PrimaryGlass(pressed: _pressed, label: widget.label)
            : _SecondaryGlass(pressed: _pressed, label: widget.label),
      ),
    );
  }
}

// ─── PRIMARY ──────────────────────────────────────────────────────────────────

class _PrimaryGlass extends StatelessWidget {
  final bool pressed;
  final String label;

  const _PrimaryGlass({required this.pressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C8EFF).withOpacity(0.50),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF3C8EFF).withOpacity(0.30),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color(0xFF3C8EFF)),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _GlassRimPainter(
                  borderRadius: 32,
                  topColor: Colors.white.withOpacity(0.55),
                  bottomColor: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            if (pressed)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.08)),
              ),
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECONDARY ────────────────────────────────────────────────────────────────

class _SecondaryGlass extends StatelessWidget {
  final bool pressed;
  final String label;

  const _SecondaryGlass({required this.pressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _GlassFill(
          pressed: pressed,
          borderRadius: 32,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SMALL GLASS BUTTON (SKIP / ICON) ─────────────────────────────────────────

class _SmallGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSquare;

  const _SmallGlassButton({
    required this.onPressed,
    required this.child,
    this.isSquare = false,
  });

  @override
  State<_SmallGlassButton> createState() => _SmallGlassButtonState();
}

class _SmallGlassButtonState extends State<_SmallGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 44,
          width: widget.isSquare ? 44 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _GlassFill(
              pressed: _pressed,
              borderRadius: 22,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isSquare ? 0 : 18,
                ),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SHARED GLASS FILL (frosted white layers) ─────────────────────────────────

class _GlassFill extends StatelessWidget {
  final bool pressed;
  final double borderRadius;
  final Widget child;

  const _GlassFill({
    required this.pressed,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.88),
                  Colors.white.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 18,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.70),
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
              topColor: Colors.white.withOpacity(0.90),
              bottomColor: const Color(0xFFDDE0E5).withOpacity(0.60),
            ),
          ),
        ),
        if (pressed)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.04)),
          ),
        child,
      ],
    );
  }
}

// ─── GLASS RIM PAINTER ────────────────────────────────────────────────────────

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
