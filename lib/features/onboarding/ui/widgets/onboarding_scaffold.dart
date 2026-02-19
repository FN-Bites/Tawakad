import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/entry_header.dart';

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
    this.mascot,
    this.bottom,
  });

  final int currentStep; // 1-based
  final int totalSteps;

  final VoidCallback? onBack;
  final String title;
  final Widget child;

  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final Widget? mascot;

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
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: OnboardingProgressBar(progress: progress),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: EntryHeader(onBack: onBack),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OnboardingProgressText(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                height: 150,
                child: OverflowBox(
                  maxWidth: 180,
                  maxHeight: 240,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 160,
                    height: 240,
                    child: mascot ?? const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPrimaryPressed,
                  child: Text(
                    primaryButtonText,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
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
