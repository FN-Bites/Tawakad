import 'package:flutter/material.dart';
import 'package:tawakad_app/features/onboarding/ui/animation/phone_rive.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_screens/onboarding_page.dart';
import 'package:tawakad_app/features/onboarding/model/onboarding_model.dart';
import 'package:tawakad_app/features/onboarding/ui/pages/onboarding_questions/onboarding_questions_page.dart';
import 'package:tawakad_app/features/signIn/ui/pages/sign_in_page.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.topRight,
                child: GlassBackButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnboardingPage(
                        initialPage: onboardingSteps.length - 1,
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: PhoneRive(),
              ),
              Text(
                'أمستعد لبدء رحلتك مع توكد؟',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'أنشئ حسابًا أو سجل الدخول لبدء التجربة والاستفادة من المميزات',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              AppLiquidButtons.primary(
                label: 'ابدأ',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingQuestionsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AppLiquidButtons.secondary(
                label: 'تسجيل دخول',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignInPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
