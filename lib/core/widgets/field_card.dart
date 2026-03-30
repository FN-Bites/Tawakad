import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class FieldCard extends StatelessWidget {
  const FieldCard({
    super.key,
    required this.children,
    this.gap = 12,
  });

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}
