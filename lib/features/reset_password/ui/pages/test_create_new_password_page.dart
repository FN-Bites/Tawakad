import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../state/reset_password_flow_provider.dart';

import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../../../../core/widgets/singin_singup/password_strength_hints.dart';
import '../../../../core/widgets/entry_header.dart';

import '../../../../core/routes.dart';

class TestCreateNewPasswordPage extends StatelessWidget {
  const TestCreateNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ResetPasswordFlowProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'إنشاء كلمة مرور جديدة',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                hint: 'كلمة المرور الجديدة',
                controller: flow.newPasswordController,
                invalid: flow.passwordInvalid,
                errorMsg: flow.passwordError ?? '',
                onChanged: (_) => flow.clearServerError(),
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                hint: 'تأكيد كلمة المرور',
                controller: flow.confirmPasswordController,
                invalid: flow.passwordInvalid,
                errorMsg: flow.passwordError ?? '',
                onChanged: (_) => flow.clearServerError(),
                keyboardType: TextInputType.visiblePassword,
              ),
              // const SizedBox(height: 16),
              // // قوة كلمة المرور
              // PasswordStrengthHints(
              //   hasMinLength: flow.hasMinLength,
              //   hasNumber: flow.hasNumber,
              //   hasUppercase: flow.hasUppercase,
              //   hasLowercase: flow.hasLowercase,
              //   hasSpecialChar: flow.hasSpecialChar,
              // ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await flow.setNewPassword();
                    if (flow.serverError == null &&
                        !flow.passwordInvalid &&
                        context.mounted) {
                      flow.reset();
                      Navigator.pushNamed(
                          context, AppRoutes.testCreateNewPassword);
                    }
                  },
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
