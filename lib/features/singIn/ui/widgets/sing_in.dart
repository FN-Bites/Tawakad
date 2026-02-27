import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/widgets/auth_text_field.dart';

import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../../../../core/widgets/singin_singup/password_strength_hints.dart';

class SignIn extends StatelessWidget {
  final Map<String, TextEditingController>
      controllers; // تتحكم بالقيم في الحقول
  final Map<String, String?> errors; // رسائل الأخطاء لكل حقل
  final Map<String, ValueChanged<String>>
      onChangedCallbacks; // ما يحدث عند تعديل الحقول

  const SignIn({
    super.key,
    required this.controllers,
    required this.errors,
    required this.onChangedCallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'hint': 'البريد الإلكتروني', 'key': 'email', 'isPassword': false},
      {'hint': 'كلمة المرور', 'key': 'password', 'isPassword': true},
    ];

    return Column(
      children: [
        // الحقول
        for (var field in fields) ...[
          AuthTextField(
            hint: field['hint'] as String,
            controller: controllers[field['key'] as String]!,
            invalid: errors[field['key'] as String] != null,
            errorMsg: errors[field['key'] as String] ?? '',
            keyboardType: TextInputType.text,
            onChanged: onChangedCallbacks[field['key'] as String]!,
          ),
          const SizedBox(height: 16),
        ],
        // زر تسجيل الدخول باستخدام Google
        GoogleSignInButton(
          onPressed: () {},
        ),
      ],
    );
  }
}
