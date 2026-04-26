import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/logo_glitter_rive.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/lists_rive.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/mascot_rive.dart';
import 'package:tawakad_app/core/widgets/animation/scanning_rive.dart';
import 'onboarding_data.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingStep step;

  const OnboardingContent({super.key, required this.step});

  Widget _buildAnimation(double size) {
    switch (step.animation) {
      case OnboardingAnimation.logoGlitter:
        return const SizedBox(
          width: 230,
          height: 230,
          child: LogoGlitterRive(),
        );
      case OnboardingAnimation.lists:
        return SizedBox(
          width: size,
          height: size,
          child: const ListsRive(),
        );
      case OnboardingAnimation.mascot:
        return SizedBox(
          width: size * 0.85,
          height: size * 0.85,
          child: const MascotRive(state: MascotState.chat),
        );
      case OnboardingAnimation.scanning:
        return SizedBox(
          width: size,
          height: size,
          child: const ScanningRive(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final animationSize = (h * 0.42).clamp(220.0, 380.0);

        return Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.15),
              child: _buildAnimation(animationSize),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                    child: Text(
                      step.body,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.placeholder,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
