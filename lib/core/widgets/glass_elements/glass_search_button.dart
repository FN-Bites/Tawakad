import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class GlassSearchButton extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClosed;
  final String hintText;

  const GlassSearchButton({
    super.key,
    this.onChanged,
    this.onClosed,
    this.hintText = 'Search',
  });

  @override
  State<GlassSearchButton> createState() => _GlassSearchButtonState();
}

class _GlassSearchButtonState extends State<GlassSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _widthFactor;
  late Animation<double> _contentFade;
  late Animation<double> _cancelFade;

  bool _isExpanded = false;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const double _buttonSize = 48.0;
  static const double _gap = 10.0;
  // left padding(14) + icon(24) + gap(8) + right padding(14) = 60
  static const double _leadingArea = 60.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _widthFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _cancelFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _isExpanded = true);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _close() {
    _focusNode.unfocus();
    _textCtrl.clear();
    widget.onChanged?.call('');
    widget.onClosed?.call();
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _isExpanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppDarkColors.textPrimary : AppColors.textPrimary;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: _buttonSize,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width - 48;

            final expandedBarWidth = totalWidth - _buttonSize - _gap;

            return AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final barWidth = _buttonSize +
                    (expandedBarWidth - _buttonSize) * _widthFactor.value;

                final textFieldWidth =
                    (barWidth - _leadingArea).clamp(0.0, double.infinity);

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Search bar ─────────────────────────
                    _GlassCapsule(
                      width: barWidth,
                      height: _buttonSize,
                      onTap: _isExpanded ? null : _open,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left padding then icon in a fixed square
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: Icon(
                                Icons.search_rounded,
                                size: 24,
                                color: iconColor,
                              ),
                            ),
                          ),
                          // Text field — transparent, no background
                          if (_isExpanded)
                            FadeTransition(
                              opacity: _contentFade,
                              child: SizedBox(
                                width: textFieldWidth,
                                height: _buttonSize,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 14),
                                  child: Center(
                                    child: TextField(
                                      controller: _textCtrl,
                                      focusNode: _focusNode,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      onChanged: widget.onChanged,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        height: 1.2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.hintText,
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: textColor.withOpacity(0.35),
                                          height: 1.2,
                                        ),
                                        // Remove every border and background
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        isDense: true,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Cancel button ──────────────────────
                    if (_isExpanded)
                      FadeTransition(
                        opacity: _cancelFade,
                        child: Padding(
                          padding: const EdgeInsets.only(left: _gap),
                          child: _GlassCapsule(
                            width: _buttonSize,
                            height: _buttonSize,
                            onTap: _close,
                            child: SizedBox.expand(
                              child: Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Glass capsule ─────────────────────────────────────────────────────────

class _GlassCapsule extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Widget child;

  const _GlassCapsule({
    required this.width,
    required this.height,
    required this.child,
    this.onTap,
  });

  @override
  State<_GlassCapsule> createState() => _GlassCapsuleState();
}

class _GlassCapsuleState extends State<_GlassCapsule>
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
    final radius = widget.height / 2;

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = true);
              _ctrl.forward();
            },
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              _ctrl.reverse();
              widget.onTap?.call();
            },
      onTapCancel: widget.onTap == null
          ? null
          : () {
              setState(() => _pressed = false);
              _ctrl.reverse();
            },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
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
            borderRadius: BorderRadius.circular(radius),
            child: _GlassFill(
              pressed: _pressed,
              borderRadius: radius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass fill ────────────────────────────────────────────────────────────
// blur → single flat tint → rim. Nothing else. No shimmer. No banding.

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tint = isDark
        ? AppDarkColors.surface.withOpacity(0.55)
        : AppColors.surface.withOpacity(0.62);

    final rimTop = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.80);
    final rimBottom = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.20);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: const SizedBox.expand(),
        ),
        // 2. Single flat tint — one color, no gradient
        Container(color: tint),
        // 3. Rim stroke
        CustomPaint(
          painter: _GlassRimPainter(
            borderRadius: borderRadius,
            topColor: rimTop,
            bottomColor: rimBottom,
          ),
        ),
        // 4. Press overlay
        if (pressed)
          Container(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.06),
          ),
        // 5. Child — must be transparent itself
        child,
      ],
    );
  }
}

// ─── Rim painter ───────────────────────────────────────────────────────────

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
