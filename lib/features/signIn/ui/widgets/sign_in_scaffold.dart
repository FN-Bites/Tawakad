import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/widgets/glass_elements/google_glass_button.dart';
import 'password_bottom_action_text.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

class SignInScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final VoidCallback? onGooglePressed;

  final String forgotPasswordText;
  final VoidCallback? onForgotPasswordPressed;

  final String bottomPrefixText;
  final String bottomActionText;
  final VoidCallback? onBottomActionPressed;

  final VoidCallback? onBack;

  const SignInScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.onGooglePressed,
    required this.forgotPasswordText,
    this.onForgotPasswordPressed,
    required this.bottomPrefixText,
    required this.bottomActionText,
    this.onBottomActionPressed,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GlassBackButton(onPressed: onBack),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      child,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PasswordBottomActionText(
                          actionText: forgotPasswordText,
                          onTap: onForgotPasswordPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AppLiquidButtons.primary(
                label: primaryButtonText,
                onPressed: onPrimaryPressed,
              ),
              const SizedBox(height: 20),
              GoogleSignInButton(onPressed: onGooglePressed),
              const SizedBox(height: 30),
              EntryBottomActionText(
                prefixText: bottomPrefixText,
                actionText: bottomActionText,
                onTap: onBottomActionPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
