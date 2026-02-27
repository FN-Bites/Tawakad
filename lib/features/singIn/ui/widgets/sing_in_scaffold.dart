import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/widgets/entry_header.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';

import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../widgets/password_bottom_action_text.dart';

class SignInScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final String? forgotPasswordText;
  final VoidCallback? onForgotPasswordPressed;

  final String bottomPrefixText; // " ليس لديك حساب؟ "
  final String bottomActionText; // " إنشاء حساب"
  final VoidCallback? onBottomActionPressed;
  final VoidCallback? onActionPressed;

  final VoidCallback? onBack;

  const SignInScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.forgotPasswordText,
    this.onForgotPasswordPressed,
    required this.bottomPrefixText,
    required this.bottomActionText,
    this.onBottomActionPressed,
    this.onActionPressed,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // زر الرجوع
              SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: onBack ?? () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: AppColors.icon,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // العنوان
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // المحتوى الأساسي
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 16),

              // زر نسيت كلمة المرور
              if (forgotPasswordText != null)
                PasswordBottomActionText(
                  actionText: forgotPasswordText!,
                  onTap: onForgotPasswordPressed,
                ),

              const SizedBox(height: 12),

              // زر أساسي
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

              const SizedBox(height: 32),

              // الفوتر باستخدام EntryBottomActionText
              EntryBottomActionText(
                prefixText: bottomPrefixText,
                actionText: bottomActionText,
                onTap: onBottomActionPressed,
              ),

              GoogleSignInButton(
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
