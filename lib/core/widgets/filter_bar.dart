import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_bar.dart';

class AppFilterBar extends StatefulWidget {
  final List<String> labels;
  final int initialIndex;
  final ValueChanged<int>? onFilterChanged;
  final double chipWidth;
  final double height;

  const AppFilterBar({
    super.key,
    required this.labels,
    this.initialIndex = 0,
    this.onFilterChanged,
    this.chipWidth = 90.0,
    this.height = 40.0,
  });

  @override
  State<AppFilterBar> createState() => _AppFilterBarState();
}

class _AppFilterBarState extends State<AppFilterBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    const pillInset = 4.0;
    final totalWidth =
        (widget.chipWidth * widget.labels.length) + (pillInset * 2);

    return GlassSurface(
      height: widget.height,
      width: totalWidth,
      selectedIndex: _selectedIndex,
      itemCount: widget.labels.length,
      pillInset: pillInset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: pillInset),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.labels.length, (i) {
            return _FilterChip(
              label: widget.labels[i],
              isSelected: i == _selectedIndex,
              width: widget.chipWidth,
              onTap: () {
                setState(() => _selectedIndex = i);
                widget.onFilterChanged?.call(i);
              },
            );
          }),
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
