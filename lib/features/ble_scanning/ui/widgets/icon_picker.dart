import 'package:flutter/material.dart';

class BleIconsPicker extends StatelessWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;

  const BleIconsPicker({
    super.key,
    required this.onIconSelected,
    required this.selectedIcon,
  });

  static const List<String> icons = [
    "assets/icons/icon_picker/1-logo.png",
    "assets/icons/icon_picker/a-list.png",
    "assets/icons/icon_picker/laptop.png",
    "assets/icons/icon_picker/ipad.png",
    "assets/icons/icon_picker/headphones.png",
    "assets/icons/icon_picker/id.png",
    "assets/icons/icon_picker/key.png",
    "assets/icons/icon_picker/bag.png",
    "assets/icons/icon_picker/glasses.png",
    "assets/icons/icon_picker/charger.png",
    "assets/icons/icon_picker/wallet.png",
    "assets/icons/icon_picker/bottle.png",
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
              padding: const EdgeInsets.all(4),
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
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    icon,
                    fit: BoxFit.contain,
                    color: iconColor,
                    colorBlendMode: BlendMode.srcIn,
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
