import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import '../../../../core/widgets/glass_elements/google_glass_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/widgets/glass_elements/app_liquid_buttons.dart';

class SignUpScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final VoidCallback? onGooglePressed;

  final String bottomPrefixText; // "لديك حساب؟ "
  final String bottomActionText; // "سجل دخول"
  final VoidCallback? onBottomActionPressed;

  final VoidCallback? onBack;

  const SignUpScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.onGooglePressed,
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
              // زر الرجوع
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GlassBackButton(onPressed: onBack),
                ),
              ),
              const SizedBox(height: 25),

              // العنوان
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),

              // المحتوى الأساسي
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 25),

              // زر أساسي
              AppLiquidButtons.primary(
                label: primaryButtonText,
                onPressed: onPrimaryPressed,
              ),
              const SizedBox(height: 20),

              GoogleSignInButton(
                onPressed: onGooglePressed,
              ),
              const SizedBox(height: 25),

              // الفوتر باستخدام EntryBottomActionText
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
