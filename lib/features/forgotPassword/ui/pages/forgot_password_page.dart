import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/glass_back_button.dart';
import '../../state/forgotPassword_flow_provider.dart';
import '../widgets/success_sheet.dart'; 
import '../../../../../../core/widgets/auth_text_field.dart';
import '../../../../../../core/theme/app_colors.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ForgotPasswordFlowProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GlassBackButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/signin',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // العنوان
              Text(
                'نسيت كلمة المرور ؟',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),

              Text(
                'أدخل بريدك الإلكتروني، وفي حال وجود حساب مرتبط به، سنقوم بإرسال تعليمات إعادة تعيين كلمة المرور الخاصة بك',
                textAlign: TextAlign.right,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 20),

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
                      const SizedBox(height: 30),
                      /// زر الإرسال
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (flow.isButtonEnabled && !flow.isLoading)
                            ? () async {
                              final success = await flow.sendPasswordResetEmail();
                                  if (success && context.mounted) {
                                    showModalBottomSheet(
                                      context: context,
                                      isDismissible: false,
                                      enableDrag: false,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                      ),
                                      backgroundColor: Colors.white,
                                      builder: (context) => const SuccessSheet(),
                                    );
                                  }
                                }
                                : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return AppColors.linkSoft.withOpacity(0.6);
                                }
                                return AppColors.primary;
                              },
                            ),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          child: Text(
                            flow.isButtonEnabled
                              ? 'إرسال'
                              : 'إعادة الإرسال بعد ${flow.resendSeconds} ثانية',
                            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
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