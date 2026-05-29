import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/widgets/glass_elements/google_glass_button.dart';
import 'password_bottom_action_text.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

class SignInScaffold extends StatefulWidget {
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
  State<SignInScaffold> createState() => _SignInScaffoldState();
}

class _SignInScaffoldState extends State<SignInScaffold> {
  bool _keyboardVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isKeyboardUp = MediaQuery.of(context).viewInsets.bottom > 100;
    if (isKeyboardUp != _keyboardVisible) {
      setState(() => _keyboardVisible = isKeyboardUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  child: GlassBackButton(onPressed: widget.onBack),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _keyboardVisible
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      widget.child,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PasswordBottomActionText(
                          actionText: widget.forgotPasswordText,
                          onTap: widget.onForgotPasswordPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              AppLiquidButtons.primary(
                label: widget.primaryButtonText,
                onPressed: widget.onPrimaryPressed,
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _keyboardVisible
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          GoogleSignInButton(onPressed: widget.onGooglePressed),
                          const SizedBox(height: 30),
                          EntryBottomActionText(
                            prefixText: widget.bottomPrefixText,
                            actionText: widget.bottomActionText,
                            onTap: widget.onBottomActionPressed,
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
