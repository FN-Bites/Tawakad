import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;

  const ColorPicker({
    super.key,
    required this.onColorSelected,
    required this.selectedColor,
  });

  static const List<Color> colors = [
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFFFFC107),
    Color(0xFF4CAF50),
    Color(0xFF00BCD4),
    Color(0xFF1E88E5),
    Color(0xFF5E5CE6),
    Color(0xFFFF5A7A),
    Color(0xFF9C6BCF),
    Color(0xFFA67C52),
    Color(0xFF8E8E93),
    Color(0xFFB7849B),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: colors.map((color) {
        final isSelected = selectedColor == color;

        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFB7B7B9) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
