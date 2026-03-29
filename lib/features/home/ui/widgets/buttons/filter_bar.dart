import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_bar.dart';

enum FilterOption { today, all, favorites }

extension FilterOptionLabel on FilterOption {
  String get label {
    switch (this) {
      case FilterOption.today:
        return 'اليوم';
      case FilterOption.all:
        return 'الكل';
      case FilterOption.favorites:
        return 'المفضل';
    }
  }
}

class GlassFilterBar extends StatefulWidget {
  final FilterOption initialFilter;
  final ValueChanged<FilterOption>? onFilterChanged;
  final double chipWidth;
  final double height;

  const GlassFilterBar({
    super.key,
    this.initialFilter = FilterOption.today,
    this.onFilterChanged,
    this.chipWidth = 90.0,
    this.height = 40.0,
  });

  @override
  State<GlassFilterBar> createState() => _GlassFilterBarState();
}

class _GlassFilterBarState extends State<GlassFilterBar> {
  late FilterOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    const options = FilterOption.values;
    const pillInset = 4.0;
    final totalWidth = (widget.chipWidth * options.length) + (pillInset * 2);
    final selectedIndex = options.indexOf(_selected);

    return GlassSurface(
      height: widget.height,
      width: totalWidth,
      selectedIndex: selectedIndex,
      itemCount: options.length,
      pillInset: pillInset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: pillInset),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return _FilterChip(
              label: option.label,
              isSelected: option == _selected,
              width: widget.chipWidth,
              onTap: () {
                setState(() => _selected = option);
                widget.onFilterChanged?.call(option);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween(begin: 1.0, end: 0.94)
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.width,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.isSelected
                    ? const Color(0xFF3C8EFF)
                    : const Color(0xFF8E8E93),
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
