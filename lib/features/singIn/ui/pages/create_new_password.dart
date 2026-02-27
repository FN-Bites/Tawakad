import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../state/signIn_flow_provider.dart';

import '../widgets/password_bottom_action_text.dart';
import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../../../../core/widgets/singin_singup/password_strength_hints.dart';
import '../../../../core/widgets/entry_header.dart';

class CreateNewPasswordPage extends StatelessWidget {
  const CreateNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<SignInFlowProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              AuthTextField(
                hint: 'كلمة المرور',
                controller: flow.passwordController,
                invalid: flow.passwordInvalid,
                errorMsg: flow.passwordError ?? flow.serverError ?? '',
                onChanged: flow.setPassword,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                hint: 'تأكيد كلمة المرور',
                controller: flow.confirmPasswordController,
                invalid: flow.confirmPasswordInvalid,
                errorMsg: flow.confirmPasswordError ?? '',
                onChanged: flow.setConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              // قوة كلمة المرور
              PasswordStrengthHints(
                hasMinLength: flow.hasMinLength,
                hasNumber: flow.hasNumber,
                hasUppercase: flow.hasUppercase,
                hasLowercase: flow.hasLowercase,
                hasSpecialChar: flow.hasSpecialChar,
              ),
              const SizedBox(height: 24),
              // زر  إعادة  تعيين
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      flow.isButtonEnabled ? () => flow.submit(context) : null,
                  child: Text(
                    'إعادة تعيين كلمة المرور',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
