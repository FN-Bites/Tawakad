import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import '../animation/mail_sent_rive.dart';
import 'package:provider/provider.dart';
import '../../state/verifyEmail_flow_provider.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<VerifyEmailFlowProvider>();
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (flow.isEmailVerified) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GlassBackButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/signup',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              const SizedBox(
                width: 130,
                height: 130,
                child: MailSendRive(),
              ),
              const SizedBox(height: 40),
              Text(
                'تحقق من بريدك الالكتروني',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 20),
              Text(
                ' أرسلنا رابط التحقق إلى ${flow.email}\nاضغط على الرابط لإكمال التحقق',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ملاحظة: يرجى التحقق من الرسائل غير المرغوب فيها (Spam) في حال لم تجد الرسالة في الوارد',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.amber[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'لم يصلك البريد؟',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      flow.canResend ? flow.resendVerificationEmail : null,
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
                    flow.canResend
                        ? 'إعادة إرسال'
                        : 'إعادة الإرسال بعد ${flow.secondsRemaining} ثانية',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
