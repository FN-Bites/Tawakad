import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class GlassSearchButton extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClosed;
  final VoidCallback? onOpened;
  final String hintText;

  const GlassSearchButton({
    super.key,
    this.onChanged,
    this.onClosed,
    this.onOpened,
    this.hintText = 'Search',
  });

  @override
  State<GlassSearchButton> createState() => _GlassSearchButtonState();
}

class _GlassSearchButtonState extends State<GlassSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  late Animation<double> _contentFade;
  late Animation<double> _cancelFade;

  bool _isExpanded = false;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const double _collapsedWidth = 52.0;
  static const double _cancelSize = 48.0;
  static const double _cancelGap = 10.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
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
    widget.onOpened?.call();
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 370), () {
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
    final iconColor = isDark ? AppDarkColors.icon : AppColors.icon;
    final capsuleColor =
        isDark ? const Color(0xFF171B22) : const Color(0xFFFFFFFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 40;

        final expandedPillW = maxW - _cancelSize - _cancelGap;

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final pillW = _collapsedWidth +
                (expandedPillW - _collapsedWidth) * _expandAnim.value;

            const leadingArea = 52.0;
            final tfW = (pillW - leadingArea).clamp(0.0, double.infinity);
            final cancelAllocW = (_cancelSize + _cancelGap) * _expandAnim.value;

            return ClipRect(
              child: SizedBox(
                width: maxW,
                height: _collapsedWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Pill ──────────────────────────────────────────────
                    _FlatCapsule(
                      width: pillW,
                      height: _collapsedWidth,
                      color: capsuleColor,
                      onTap: _isExpanded ? null : _open,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded,
                              size: 22, color: iconColor),
                          if (_isExpanded)
                            FadeTransition(
                              opacity: _contentFade,
                              child: SizedBox(
                                width: tfW,
                                height: _collapsedWidth,
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: textColor,
                                        height: 1.2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.hintText,
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              textColor.withValues(alpha: 0.35),
                                          height: 1.2,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
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

                    // ── Cancel button ─────────────────────────────────────
                    SizedBox(
                      width: cancelAllocW,
                      height: _collapsedWidth,
                      child: cancelAllocW > _cancelGap
                          ? FadeTransition(
                              opacity: _cancelFade,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: _cancelGap),
                                child: _FlatCapsule(
                                  width: _cancelSize,
                                  height: _cancelSize,
                                  color: capsuleColor,
                                  onTap: _close,
                                  child: Center(
                                    child: Icon(Icons.close_rounded,
                                        size: 20, color: iconColor),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Flat capsule — no blur, no shadow, no rim ────────────────────────────

class _FlatCapsule extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final VoidCallback? onTap;
  final Widget child;

  const _FlatCapsule({
    required this.width,
    required this.height,
    required this.color,
    required this.child,
    this.onTap,
  });

  @override
  State<_FlatCapsule> createState() => _FlatCapsuleState();
}

class _FlatCapsuleState extends State<_FlatCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
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
      onTapDown: widget.onTap == null ? null : (_) => _ctrl.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap?.call();
            },
      onTapCancel: widget.onTap == null ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(radius),
            // No shadow
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
