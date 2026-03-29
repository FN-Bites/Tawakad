import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

class PackListIconBadge extends StatelessWidget {
  const PackListIconBadge({
    super.key,
    required this.icon,
    this.onPressed,
    this.bold = false,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool bold;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppLiquidButtons.icon(
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
      iconSize: 24,
      bold: bold,
    );
  }
}
