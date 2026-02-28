import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../state/signIn_flow_provider.dart';

import '../widgets/password_bottom_action_text.dart';
import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../../../../core/widgets/entry_header.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
              EntryHeader(),
              // العنوان
              Text(
                'تسجيل الدخول',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // الحقول + رسائل الخطأ
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      AuthTextField(
                        hint: 'البريد الإلكتروني',
                        controller: flow.emailController,
                        invalid: flow.emailInvalid,
                        errorMsg: flow.emailError ?? flow.serverError ?? '',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: flow.setEmail,
                      ),
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
                      // نسيت كلمة المرور
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PasswordBottomActionText(
                          actionText: 'نسيت كلمة المرور؟',
                          onTap: () {
                            Navigator.pushNamed(context, '/forget-password');
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // زر تسجيل الدخول
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: flow.isButtonEnabled
                              ? () => flow.submit(context)
                              : null,
                          child: Text(
                            'تسجيل الدخول',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // زر تسجيل الدخول باستخدام Google
              GoogleSignInButton(
                onPressed: () {
                  print("تسجيل الدخول باستخدام Google");
                },
              ),

              const SizedBox(height: 16),

              // Footer
              EntryBottomActionText(
                prefixText: 'ليس لديك حساب؟ ',
                actionText: 'قم بإنشاء حساب',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
