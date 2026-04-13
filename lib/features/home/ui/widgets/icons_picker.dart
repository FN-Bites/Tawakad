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
    "assets/icons/icon_picker/1-logo.png",
    "assets/icons/icon_picker/a-list.png",
    "assets/icons/icon_picker/a-location.png",
    "assets/icons/icon_picker/backpack.png",
    "assets/icons/icon_picker/bank.png",
    "assets/icons/icon_picker/beach.png",
    "assets/icons/icon_picker/building.png",
    "assets/icons/icon_picker/gym.png",
    "assets/icons/icon_picker/graduation.png",
    "assets/icons/icon_picker/home.png",
    "assets/icons/icon_picker/hospitle.png",
    "assets/icons/icon_picker/mosque.png",
    "assets/icons/icon_picker/party.png",
    "assets/icons/icon_picker/plane.png",
    "assets/icons/icon_picker/stadium.png",
    "assets/icons/icon_picker/teepee.png",
    "assets/icons/icon_picker/tree.png",
    "assets/icons/icon_picker/work.png",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

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
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFB7B7B9)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(icon,
                      fit: BoxFit.contain,
                      color: iconColor,
                      colorBlendMode: BlendMode.srcIn),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
