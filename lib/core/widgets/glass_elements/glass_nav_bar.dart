import 'package:flutter/material.dart';

class GlassNavItem {
  final String assetPath;
  final String label;

  const GlassNavItem({required this.assetPath, required this.label});
}

class GlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : assert(items.length == 3, 'GlassNavBar requires exactly 3 items');

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _indicatorPos;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorPos = AlwaysStoppedAnimation(widget.currentIndex.toDouble());
  }

  @override
  void didUpdateWidget(GlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _indicatorPos.value;
      _indicatorPos = Tween<double>(
        begin: from,
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF171B22) : const Color(0xFFFFFFFF);
    final activeBg = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFF000000).withOpacity(0.06);

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(60),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemW = constraints.maxWidth / widget.items.length;

          return Stack(
            children: [
              // ── Sliding indicator ──────────────────────────────────────
              AnimatedBuilder(
                animation: _indicatorPos,
                builder: (context, _) {
                  final rtlPos =
                      (widget.items.length - 1) - _indicatorPos.value;
                  final left = rtlPos * itemW;

                  final nearestIndex = _indicatorPos.value
                      .round()
                      .clamp(0, widget.items.length - 1);
                  final isFirst = nearestIndex == 0;
                  final isLast = nearestIndex == widget.items.length - 1;

                  final radius = BorderRadius.only(
                    topLeft: isLast
                        ? const Radius.circular(60)
                        : const Radius.circular(50),
                    bottomLeft: isLast
                        ? const Radius.circular(60)
                        : const Radius.circular(50),
                    topRight: isFirst
                        ? const Radius.circular(60)
                        : const Radius.circular(50),
                    bottomRight: isFirst
                        ? const Radius.circular(60)
                        : const Radius.circular(50),
                  );

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    width: itemW,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: activeBg,
                        borderRadius: radius,
                      ),
                    ),
                  );
                },
              ),

              // ── Nav item tiles ─────────────────────────────────────────
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: List.generate(widget.items.length, (index) {
                    return Expanded(
                      child: _NavItemTile(
                        item: widget.items[index],
                        isActive: widget.currentIndex == index,
                        isDark: isDark,
                        onTap: () => widget.onTap(index),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Individual tile ────────────────────────────────────────────────────────

class _NavItemTile extends StatefulWidget {
  final GlassNavItem item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavItemTile> createState() => _NavItemTileState();
}

class _NavItemTileState extends State<_NavItemTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0091FF);
    final inactiveColor =
        widget.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox.expand(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    widget.isActive
                        ? activeColor
                        : inactiveColor.withOpacity(0.70),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    widget.item.assetPath,
                    width: 36,
                    height: 36,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.0,
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isActive
                        ? activeColor
                        : inactiveColor.withOpacity(0.60),
                  ),
                  child: Text(
                    widget.item.label,
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
