import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/auth_text_field.dart';
import '../../../../core/widgets/entry_bottom_action_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../state/signIn_flow_provider.dart';

import '../widgets/password_bottom_action_text.dart';
import '../../../../core/widgets/singin_singup/google_signIn_button.dart';
import '../../../../core/widgets/entry_header.dart';

class ForgetThePasswordPage extends StatelessWidget {
  const ForgetThePasswordPage({super.key});

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
                ' نسيت كلمة المرور ؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                  '.أدخل عنوان بريدك الإلكتروني أدناه، وسنرسل لك تعليمات لإعادة تعيين كلمة المرور الخاصة بك',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelMedium),
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
                      // زر الارسال
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return AppColors
                                      .linkSoft; // اللون عند التعطيل
                                }
                                return AppColors.primary; // اللون عند التفعيل
                              },
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: flow.isButtonEnabled
                              ? () => flow.submit(context)
                              : null,
                          child: Text(
                            flow.isButtonEnabled
                                ? 'إرسال'
                                : 'إعادة إرسال بعد ٣٠ ثانية',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ],
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
