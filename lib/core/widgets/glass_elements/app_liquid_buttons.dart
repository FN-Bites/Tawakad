import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

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
        child: _ThemedText(label: label, textStyle: textStyle),
      );

  static Widget icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? iconColor,
    double iconSize = 18,
    bool bold = false,
    List<BoxShadow>? shadows,
  }) =>
      _SmallGlassButton(
        onPressed: onPressed,
        isSquare: true,
        shadows: shadows,
        child: bold
            ? _BoldIconBuilder(icon: icon, color: iconColor, size: iconSize)
            : _ThemedIcon(icon: icon, color: iconColor, size: iconSize),
      );
}

// ─── Theme-aware helpers ───────────────────────────────────────────────────

class _ThemedText extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;

  const _ThemedText({required this.label, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: textStyle ??
          TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppDarkColors.textPrimary : AppColors.textPrimary,
          ),
    );
  }
}

class _ThemedIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const _ThemedIcon({required this.icon, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor =
        color ?? (isDark ? AppDarkColors.icon : AppColors.icon);
    return Icon(icon, color: resolvedColor, size: size);
  }
}

class _BoldIconBuilder extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const _BoldIconBuilder({required this.icon, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor =
        color ?? (isDark ? AppDarkColors.icon : AppColors.icon);
    return CustomPaint(
      size: Size(size, size),
      painter: _BoldIconPainter(
        icon: icon,
        color: resolvedColor,
        size: size,
        strokeExtra: 1,
      ),
    );
  }
}

// ─── Liquid button (primary / secondary) ──────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isDark ? 0.25 : 0.40),
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
          tint: AppColors.primary,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white, // always white on blue
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
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
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppDarkColors.textPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Small glass button ────────────────────────────────────────────────────

class _SmallGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSquare;
  final double height;
  final List<BoxShadow>? shadows;

  const _SmallGlassButton({
    required this.onPressed,
    required this.child,
    this.isSquare = false,
    this.height = 44,
    this.shadows,
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
            boxShadow: widget.shadows ??
                [
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

// ─── Glass fill ────────────────────────────────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedTint = tint ??
        (isDark
            ? AppDarkColors.surface.withOpacity(0.55)
            : AppColors.surface.withOpacity(0.62));

    final rimTop = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.80);

    final rimBottom = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.20);

    final shimmerStart = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.45);

    return Stack(
      children: [
        // Blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox.expand(),
          ),
        ),
        // Tint
        Positioned.fill(
          child: Container(color: resolvedTint),
        ),
        // Top shimmer
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
                colors: [shimmerStart, Colors.white.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        // Rim
        Positioned.fill(
          child: CustomPaint(
            painter: _GlassRimPainter(
              borderRadius: borderRadius,
              topColor: rimTop,
              bottomColor: rimBottom,
            ),
          ),
        ),
        // Press overlay
        if (pressed)
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
        child,
      ],
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────

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
