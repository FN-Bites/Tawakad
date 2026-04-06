import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

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

class AppGlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final Widget? icon;

  final String primaryLabel;
  final String secondaryLabel;

  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  /// When true the primary button uses [primaryDestructiveColor] as its tint.
  final bool isPrimaryDestructive;

  /// Override the destructive accent. Defaults to a red tone.
  final Color primaryDestructiveColor;

  /// Title text style override.
  final TextStyle? titleStyle;

  /// Body text style override.
  final TextStyle? messageStyle;

  const AppGlassDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.icon,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.isPrimaryDestructive = false,
    this.primaryDestructiveColor = const Color(0xFFE53935),
    this.titleStyle,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.14),
            blurRadius: 50,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: _GlassFill(
          pressed: false,
          borderRadius: 28,
          tint: isDark
              ? const Color(0xFF1A2E2C).withOpacity(0.60)
              : const Color(0xFFDEF5F2).withOpacity(0.72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──────────────────────────────────────────────────
                if (icon != null) ...[
                  icon!,
                  const SizedBox(height: 14),
                ],
                // ── Title ─────────────────────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle ??
                      TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppDarkColors.textPrimary
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 10),
                // ── Message ───────────────────────────────────────────────
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
                            ? AppDarkColors.textPrimary.withOpacity(0.65)
                            : AppColors.textPrimary.withOpacity(0.60),
                      ),
                ),
                const SizedBox(height: 26),
                // ── Buttons ───────────────────────────────────────────────
                Row(
                  children: [
                    // Secondary (left in RTL = visually right, cancel-like)
                    Expanded(
                      child: _DialogGlassButton(
                        label: secondaryLabel,
                        onPressed: onSecondaryPressed,
                        tint: null,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Primary
                    Expanded(
                      child: _DialogGlassButton(
                        label: primaryLabel,
                        onPressed: onPrimaryPressed,
                        tint: isPrimaryDestructive
                            ? primaryDestructiveColor
                            : AppColors.primary,
                        isDark: isDark,
                        isAccent: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dialog button ─────────────────────────────────────────────────────────

class _DialogGlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? tint;
  final bool isDark;
  final bool isAccent;

  const _DialogGlassButton({
    required this.label,
    required this.onPressed,
    required this.tint,
    required this.isDark,
    this.isAccent = false,
  });

  @override
  State<_DialogGlassButton> createState() => _DialogGlassButtonState();
}

class _DialogGlassButtonState extends State<_DialogGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
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
    final labelColor = widget.isAccent
        ? Colors.white
        : (widget.isDark ? AppDarkColors.textPrimary : AppColors.textPrimary);

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
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.tint ?? Colors.black)
                    .withOpacity(widget.isAccent ? 0.28 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _GlassFill(
              pressed: _pressed,
              borderRadius: 24,
              tint: widget.tint != null
                  ? widget.tint!.withOpacity(widget.isDark ? 0.65 : 0.80)
                  : null,
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
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
