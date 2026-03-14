import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/glass_back_button.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/mascot_rive.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/mascot_with_bubble.dart';
import 'onboarding_progress_bar.dart';
import 'onboarding_progress_text.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    required this.mascotState,
    required this.mascotMessage,
    this.isError = false,
    this.showBubble = true,
    this.bottom,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final String title;
  final Widget child;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final MascotState mascotState;
  final String mascotMessage;
  final bool isError;
  final bool showBubble;

  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSteps <= 0 ? 0.0 : (currentStep / totalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 186,
                      child: OnboardingProgressBar(progress: progress),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlassBackButton(onPressed: onBack),
                    ),
                  ],
                ),
              ),
              OnboardingProgressText(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
              const SizedBox(height: 8),
              MascotWithBubble(
                mascotState: mascotState,
                message: mascotMessage,
                isError: isError,
                showBubble: showBubble,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 16),
              AppLiquidButtons.primary(
                label: primaryButtonText,
                onPressed: onPrimaryPressed ?? () {},
              ),
              if (bottom != null) ...[
                const SizedBox(height: 28.5),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
