import 'package:flutter/material.dart';

class IconsPicker extends StatelessWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;

  const IconsPicker({
    super.key,
    required this.onIconSelected,
    required this.selectedIcon,
  });

  static const List<String> icons = [
    "assets/Icons/list.bullet.png",
    "assets/Icons/airplane.up.forward.png",
    "assets/Icons/backpack.fill.png",
    "assets/Icons/beach.umbrella.png",
    "assets/Icons/birthday.cake.png",
    "assets/Icons/building.2.fill.png",
    "assets/Icons/car.fill.png",
    "assets/Icons/cloud.drizzle.fill.png",
    "assets/Icons/dumbbell.png",
    "assets/Icons/flame.fill.png",
    "assets/Icons/gamecontroller.fill.png",
    "assets/Icons/graduationcap.fill.png",
    "assets/Icons/snowflake.png",
    "assets/Icons/stethoscope.png",
    "assets/Icons/suitcase.fill.png",
    "assets/Icons/sun.min.fill.png",
    "assets/Icons/tent.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.count(
        crossAxisCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: icons.map((icon) {
          final isSelected = selectedIcon == icon;

          return GestureDetector(
            onTap: () => onIconSelected(icon),
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
                  child: Image.asset(
                    icon,
                    width: 28,
                    height: 24,
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
