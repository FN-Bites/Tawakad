import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/animation/phone_rive.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_page.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/app_liquid_buttons.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // ── Animation ──────────────────────────────────────────────
              const SizedBox(
                height: 40,
                width: 40,
                child: PhoneRive(),
              ),

              // ── Title + subtitle ───────────────────────────────────────
              Text(
                'توكد',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'تذكيرك الذكي لكل يوم',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 96),

              // ── Buttons ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 54),
                child: Column(
                  children: [
                    AppLiquidButtons.primary(
                      label: 'ابدأ',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppLiquidButtons.secondary(
                      label: 'تسجيل دخول',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
