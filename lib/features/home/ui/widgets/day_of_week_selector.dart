import 'package:flutter/material.dart';

class DayOfWeekSelector extends StatelessWidget {
  final List<int> selectedDays; // 0 = Sunday … 6 = Saturday
  final ValueChanged<List<int>> onChanged;

  const DayOfWeekSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const _days = [
    (label: 'أحد', index: 0),
    (label: 'اثنين', index: 1),
    (label: 'ثلاثاء', index: 2),
    (label: 'أربعاء', index: 3),
    (label: 'خميس', index: 4),
    (label: 'جمعة', index: 5),
    (label: 'سبت', index: 6),
  ];

  void _toggle(int dayIndex) {
    final updated = List<int>.from(selectedDays);
    if (updated.contains(dayIndex)) {
      updated.remove(dayIndex);
    } else {
      updated.add(dayIndex);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _days.map((day) {
          final isSelected = selectedDays.contains(day.index);
          return _DayBubble(
            label: day.label,
            isSelected: isSelected,
            onTap: () => _toggle(day.index),
          );
        }).toList(),
      ),
    );
  }
}

class _DayBubble extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayBubble({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFF1F8EFA).withOpacity(0.18)
              : const Color(0xFFE8F0FB),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F8EFA) : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1F8EFA).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1F8EFA)
                  : const Color(0xFF8AAFE8),
            ),
          ),
        ),
      ),
    );
  }
}
