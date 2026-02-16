import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterStepContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasMinLength;
  final bool hasSpecialChar;

  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;

  const RegisterStepContent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasMinLength,
    required this.hasSpecialChar,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          hint: 'البريد الإلكتروني',
          controller: emailController,
          errorText: emailError,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'كلمة المرور',
          controller: passwordController,
          isPassword: true,
          errorText: passwordError,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'تأكيد كلمة المرور',
          controller: confirmPasswordController,
          isPassword: true,
          errorText: confirmPasswordError,
          onChanged: onConfirmPasswordChanged,
        ),
        const SizedBox(height: 16),
        PasswordStrengthHints(
          hasMinLength: hasMinLength,
          hasNumber: hasNumber,
          hasUppercase: hasUppercase,
          hasLowercase: hasLowercase,
          hasSpecialChar: hasSpecialChar,
        ),
      ],
    );
  }
}

class AuthScaffold extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  final VoidCallback? onBack;
  final String title;
  final Widget child;

  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final String bottomPrefixText; // "لديك حساب؟ "
  final String bottomActionText; // "قم بتسجيل الدخول"
  final VoidCallback? onBottomActionPressed;

  const AuthScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    required this.bottomPrefixText,
    required this.bottomActionText,
    this.onBottomActionPressed,
  });

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
          // Restricted content area from design
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header:  back button right
              SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Progress bar
                    Align(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

              const SizedBox(height: 8),

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
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "أو",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBDBDBD), // لون النص
                      ),
                      //style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  GoogleSignInButton(
                    onPressed: () {
                      // تسجيل الدخول بقوقل
                    },
                  ),

                  const SizedBox(height: 28), // مسافة قبل الفوتر

                  RichText(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: bottomPrefixText,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.linkSoft,
                                  ),
                        ),
                        TextSpan(
                          text: bottomActionText,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = onBottomActionPressed,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invalid = errorText != null && errorText!.isNotEmpty;

    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor:
                invalid ? const Color(0xFFFFEEEE) : const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color:
                    invalid ? const Color(0xFFFF4D4F) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color:
                    invalid ? const Color(0xFFFF4D4F) : const Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color:
                    invalid ? const Color(0xFFFF4D4F) : const Color(0xFF0066FF),
                width: 1.4,
              ),
            ),
          ),
        ),
        if (invalid) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              errorText!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFFF4D4F),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PasswordStrengthHints extends StatelessWidget {
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasMinLength;
  final bool hasSpecialChar;
  final bool hasLowercase;

  const PasswordStrengthHints({
    super.key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasSpecialChar,
  });

  Widget _buildRow(String text, bool ok) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: text.isEmpty
              ? const Color(0x6A7282) // رمادي
              : ok
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFEB5757),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: text.isEmpty
                ? const Color(0x6A7282) // رمادي
                : ok
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFEB5757),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('لا تقل عن 8 أحرف', hasMinLength),
        const SizedBox(height: 2),
        _buildRow('تحتوي على رقم واحد على الأقل', hasNumber),
        const SizedBox(height: 2),
        _buildRow('تحتوي على حرف كبير واحد على الأقل', hasUppercase),
        const SizedBox(height: 2),
        _buildRow('تحتوي على حرف صغير واحد على الأقل', hasLowercase),
        const SizedBox(height: 2),
        _buildRow('تحتوي على رمز خاص واحد على الأقل', hasSpecialChar),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent, // خلفية شفافة
        side: const BorderSide(
            color: Color(0xFFBDBDBD), width: 1.2), // حدود رمادية
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // مستدير الحواف
        ),
        padding: const EdgeInsets.symmetric(vertical: 14), // ارتفاع أكبر للزر
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة Google
          Image.asset(
            'assets/Icons/Google.png',
            height: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            'Google تسجيل باستخدام',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 40, 44, 56), // نص أسود على خلفية شفافة
            ),
          ),
        ],
      ),
    );
  }
}
