import 'package:flutter/material.dart';
import '../../../../core/widgets/singin_singup/sign_auth_text_field.dart';
import '../../../../core/widgets/singin_singup/password_strength_hints.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class SignUpContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? registrationError;

  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasMinLength;
  final bool hasSpecialChar;
  final bool isPasswordEmpty;

  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;

  const SignUpContent({
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
    required this.registrationError,
    required this.isPasswordEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return FieldCard(
      children: [
        SignAuthTextField(
          hint: 'البريد الإلكتروني',
          controller: emailController,
          errorText: emailError,
          externalError: registrationError,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 10),
        SignAuthTextField(
          hint: 'كلمة المرور',
          controller: passwordController,
          isPassword: true,
          enableToggle: true,
          errorText: passwordError,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 10),
        SignAuthTextField(
          hint: 'تأكيد كلمة المرور',
          controller: confirmPasswordController,
          isPassword: true,
          enableToggle: true,
          errorText: confirmPasswordError,
          onChanged: onConfirmPasswordChanged,
        ),
        const SizedBox(height: 10),
        PasswordStrengthHints(
          hasMinLength: hasMinLength,
          hasNumber: hasNumber,
          hasUppercase: hasUppercase,
          hasLowercase: hasLowercase,
          hasSpecialChar: hasSpecialChar,
          isPasswordEmpty: isPasswordEmpty,
        ),
      ],
    );
  }
}
