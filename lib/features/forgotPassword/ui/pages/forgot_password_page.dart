import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/forgotPassword_flow_provider.dart';

import '../../../../../../core/widgets/auth_text_field.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/entry_header.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ForgotPasswordFlowProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EntryHeader(
                onBack: () =>
                    Navigator.pushReplacementNamed(context, '/signin'),
              ),

              const SizedBox(height: 16),

              // العنوان
              Text(
                'نسيت كلمة المرور ؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                'أدخل عنوان بريدك الإلكتروني أدناه، وسنرسل لك تعليمات لإعادة تعيين كلمة المرور الخاصة بك',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium,
              ),

              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      /// حقل البريد
                      AuthTextField(
                        hint: 'البريد الإلكتروني',
                        controller: flow.emailController,
                        invalid: flow.emailInvalid,
                        errorMsg: flow.emailError ?? flow.serverError ?? '',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: flow.setEmail,
                      ),

                      const SizedBox(height: 16),

                      /// زر الإرسال
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: flow.isButtonEnabled && !flow.isLoading
                              ? () async {
                                  await flow.sendPasswordResetEmail();
                                  if (context.mounted && flow.serverError == null) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          ' إذا كان البريد الإلكتروني مسجلاً فسيتم إرسال رابط إعادة التعيين إليه ',
                                        ),
                                      ),
                                    );
                                  }
                                }
                                : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return AppColors.linkSoft;
                                }
                                return AppColors.primary;
                              },
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          child: flow.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  flow.isButtonEnabled
                                      ? 'إرسال'
                                      : 'إعادة إرسال بعد ${flow.resendSeconds} ثانية',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge,
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