import 'package:flutter/material.dart';

class BleColorsPicker extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;

  const BleColorsPicker({
    super.key,
    required this.onColorSelected,
    required this.selectedColor,
  });

  static const List<Color> colors = [
    Color(0xFF64B5F6),
    Color(0xFF80DEEA),
    Color(0xFFEF9A9A),
    Color(0xFFFF8FA3),
    Color(0xFFFFCC80),
    Color(0xFFFFE082),
    Color(0xFFA5D6A7),
    Color(0xFF9E9CF5),
    Color(0xFFCE93D8),
    Color(0xFFD4B896),
    Color(0xFFBDBDBD),
    Color(0xFFD4A8BF),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.count(
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
                    color: isSelected
                        ? const Color(0xFFB7B7B9)
                        : Colors.transparent,
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
      ),
    );
  }
}
