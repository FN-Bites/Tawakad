import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

// ─── Dropdown model ────────────────────────────────────────────────────────

class GlassDropdownItem {
  final String label;
  final Widget? leadingIcon;
  final Widget? trailingWidget;
  final bool enabled;

  const GlassDropdownItem({
    required this.label,
    this.leadingIcon,
    this.trailingWidget,
    this.enabled = true,
  });
}

// ─── Dropdown ──────────────────────────────────────────────────────────────

class AppGlassDropdown extends StatelessWidget {
  final List<GlassDropdownItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onItemTap;
  final Color? accentColor;
  final TextStyle? labelStyle;
  final Widget? header;

  const AppGlassDropdown({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onItemTap,
    this.accentColor,
    this.labelStyle,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedAccent = accentColor ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _GlassFill(
          pressed: false,
          borderRadius: 22,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: header,
                  ),
                ),
                _GlassDivider(isDark: isDark),
              ],
              ...List.generate(items.length, (i) {
                final item = items[i];
                final isSelected = i == selectedIndex;
                final isLast = i == items.length - 1;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GlassDropdownRow(
                      item: item,
                      isSelected: isSelected,
                      accentColor: resolvedAccent,
                      labelStyle: labelStyle,
                      isDark: isDark,
                      onTap: item.enabled ? () => onItemTap?.call(i) : null,
                    ),
                    if (!isLast) _GlassDivider(isDark: isDark),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dropdown row ──────────────────────────────────────────────────────────

class _GlassDropdownRow extends StatefulWidget {
  final GlassDropdownItem item;
  final bool isSelected;
  final Color accentColor;
  final TextStyle? labelStyle;
  final bool isDark;
  final VoidCallback? onTap;

  const _GlassDropdownRow({
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    this.labelStyle,
    this.onTap,
  });

  @override
  State<_GlassDropdownRow> createState() => _GlassDropdownRowState();
}

class _GlassDropdownRowState extends State<_GlassDropdownRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
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
    final disabled = widget.onTap == null;
    final textColor = disabled
        ? (widget.isDark
            ? AppDarkColors.textPrimary.withOpacity(0.30)
            : AppColors.textPrimary.withOpacity(0.30))
        : widget.isSelected
            ? widget.accentColor
            : (widget.isDark
                ? AppDarkColors.textPrimary
                : AppColors.textPrimary);

    final resolvedStyle = (widget.labelStyle ??
            TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
            ))
        .copyWith(color: textColor);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _ctrl.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap?.call();
            },
      onTapCancel: disabled ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                if (widget.item.leadingIcon != null) ...[
                  _tinted(widget.item.leadingIcon!, textColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: resolvedStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
                if (widget.item.trailingWidget != null)
                  _tinted(widget.item.trailingWidget!, textColor)
                else if (widget.isSelected)
                  Icon(Icons.check_rounded,
                      color: widget.accentColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tinted(Widget child, Color color) => IconTheme(
        data: IconThemeData(color: color, size: 18),
        child: child,
      );
}

// ─── Dialog ────────────────────────────────────────────────────────────────

class AppGlassDialog extends StatelessWidget {
  final String title;
  final String message;

  final String primaryLabel;
  final String secondaryLabel;

  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  final bool isPrimaryDestructive;
  final Color primaryDestructiveColor;

  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  const AppGlassDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.isPrimaryDestructive = false,
    this.primaryDestructiveColor = const Color(0xFFD93025),
    this.titleStyle,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogTint = isDark
        ? const Color(0xFF1A2E2C).withOpacity(0.55)
        : const Color(0xFFD6F0EC).withOpacity(0.68);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: const SizedBox.expand(),
              ),
            ),

            // Tint
            Positioned.fill(
              child: Container(color: dialogTint),
            ),

            // Top shimmer
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.38),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Rim
            Positioned.fill(
              child: CustomPaint(
                painter: _GlassRimPainter(
                  borderRadius: 26,
                  topColor: isDark
                      ? Colors.white.withOpacity(0.18)
                      : Colors.white.withOpacity(0.72),
                  bottomColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.22),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle ??
                        TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0D1A18),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: messageStyle ??
                        TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          color: isDark
                              ? Colors.white.withOpacity(0.60)
                              : const Color(0xFF2E5550).withOpacity(0.72),
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassPillButton(
                          label: secondaryLabel,
                          textColor:
                              isDark ? Colors.white : const Color(0xFF0D1A18),
                          onPressed: onSecondaryPressed,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GlassPillButton(
                          label: primaryLabel,
                          textColor: isPrimaryDestructive
                              ? primaryDestructiveColor
                              : AppColors.primary,
                          onPressed: onPrimaryPressed,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Glass pill button ─────────────────────────────────────────────────────

class _GlassPillButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final VoidCallback? onPressed;
  final bool isDark;

  const _GlassPillButton({
    required this.label,
    required this.textColor,
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_GlassPillButton> createState() => _GlassPillButtonState();
}

class _GlassPillButtonState extends State<_GlassPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pillTint = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.36);

    final pressedOverlay = widget.isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned.fill(
                child: Container(color: pillTint),
              ),
              if (_pressed)
                Positioned.fill(
                  child: Container(color: pressedOverlay),
                ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _GlassRimPainter(
                    borderRadius: 50,
                    topColor:
                        Colors.white.withOpacity(widget.isDark ? 0.14 : 0.55),
                    bottomColor:
                        Colors.white.withOpacity(widget.isDark ? 0.03 : 0.14),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Subtle divider ────────────────────────────────────────────────────────

class _GlassDivider extends StatelessWidget {
  final bool isDark;
  const _GlassDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
      color: isDark
          ? Colors.white.withOpacity(0.10)
          : Colors.black.withOpacity(0.07),
    );
  }
}

// ─── Glass fill (used by dropdown) ────────────────────────────────────────

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

    final resolvedTint = isDark
        ? AppDarkColors.surface.withOpacity(0.55)
        : AppColors.surface.withOpacity(0.62);

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
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: Container(color: resolvedTint),
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
                colors: [shimmerStart, Colors.white.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _GlassRimPainter(
              borderRadius: borderRadius,
              topColor: rimTop,
              bottomColor: rimBottom,
            ),
          ),
        ),
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

// ─── Shared rim painter ────────────────────────────────────────────────────

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
