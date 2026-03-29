import 'package:flutter/material.dart';
import '../../../../core/widgets/singin_singup/sign_auth_text_field.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class SignInContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final String? emailError;
  final String? passwordError;
  final String? emailServerError;
  final String? passwordServerError;

  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;

  const SignInContent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.emailServerError,
    required this.passwordServerError,
  });

  @override
  Widget build(BuildContext context) {
    return FieldCard(
      children: [
        SignAuthTextField(
          hint: 'البريد الإلكتروني',
          controller: emailController,
          errorText: emailError,
          externalError: emailServerError,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 10),
        SignAuthTextField(
          hint: 'كلمة المرور',
          controller: passwordController,
          isPassword: true,
          enableToggle: true,
          errorText: passwordError,
          externalError: passwordServerError,
          onChanged: onPasswordChanged,
        ),
      ],
    );
  }
}
