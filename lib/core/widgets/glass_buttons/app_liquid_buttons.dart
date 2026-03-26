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

  static Widget custom({
    required Widget child,
    required VoidCallback? onPressed,
    double height = 44,
  }) =>
      _SmallGlassButton(onPressed: onPressed, child: child, height: height);

  static Widget small({
    required String label,
    required VoidCallback? onPressed,
    TextStyle? textStyle,
  }) =>
      _SmallGlassButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: textStyle ??
                const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
          ));

  static Widget icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color iconColor = const Color(0xFF1C1C1E),
    double iconSize = 18,
    bool bold = false,
  }) =>
      _SmallGlassButton(
        onPressed: onPressed,
        isSquare: true,
        child: bold
            ? CustomPaint(
                size: Size(iconSize, iconSize),
                painter: _BoldIconPainter(
                  icon: icon,
                  color: iconColor,
                  size: iconSize,
                  strokeExtra: 1,
                ),
              )
            : Icon(icon, color: iconColor, size: iconSize),
      );
}

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
            color: const Color(0xFF3C8EFF).withOpacity(0.40),
            blurRadius: 100,
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
          tint: const Color(0xFF3C8EFF).withOpacity(1),
          child: Center(
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
        ),
      ),
    );
  }
}

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
            color: const Color.fromARGB(255, 235, 230, 230).withOpacity(0.1),
            blurRadius: 100,
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

class _SmallGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSquare;
  final double height;

  const _SmallGlassButton({
    required this.onPressed,
    required this.child,
    this.isSquare = false,
    this.height = 44,
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
          height: widget.height,
          width: widget.isSquare ? widget.height : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
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
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: _GlassFill(
              pressed: _pressed,
              borderRadius: widget.height / 2,
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

class _GlassFill extends StatelessWidget {
  final bool pressed;
  final double borderRadius;
  final Widget child;
  final Color? tint;

  const _GlassFill({
    required this.pressed,
    required this.borderRadius,
    required this.child,
    this.tint,
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
            color: tint ?? Colors.white.withOpacity(0.62),
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
        if (pressed)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.06)),
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

class _BoldIconPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  final double size;
  final double strokeExtra;

  const _BoldIconPainter({
    required this.icon,
    required this.color,
    required this.size,
    this.strokeExtra = 2.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (double dx = -strokeExtra / 2; dx <= strokeExtra / 2; dx += 0.5) {
      for (double dy = -strokeExtra / 2; dy <= strokeExtra / 2; dy += 0.5) {
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: color,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(dx, dy));
      }
    }
  }

  @override
  bool shouldRepaint(_BoldIconPainter old) =>
      old.icon != icon ||
      old.color != color ||
      old.size != size ||
      old.strokeExtra != strokeExtra;
}
