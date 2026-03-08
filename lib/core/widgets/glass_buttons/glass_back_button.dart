import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/app_liquid_buttons.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GlassBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppLiquidButtons.icon(
      icon: Icons.arrow_back_ios_new_rounded,
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
