import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final int total;
  final int current;

  const OnboardingIndicator({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.progressBackground,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
