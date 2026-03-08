import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 5),
      child: SizedBox(
        width: 210,
        height: 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.progressBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
