import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/app_liquid_buttons.dart';

class PackListIconBadge extends StatelessWidget {
  const PackListIconBadge({
    super.key,
    required this.icon,
    this.onPressed,
    this.bold = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return AppLiquidButtons.icon(
      icon: icon,
      onPressed: onPressed,
      iconColor: const Color.fromARGB(255, 0, 0, 0),
      iconSize: 22,
      bold: bold,
    );
  }
}
