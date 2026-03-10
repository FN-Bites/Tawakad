import 'package:flutter/material.dart';
import '../../../../core/widgets/animation/mail_sent_rive.dart';
// -----------------------------------------------------------------------------
import 'package:provider/provider.dart';
import '../../state/verifyEmail_flow_provider.dart'; 
// -----------------------------------------------------------------------------

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<VerifyEmailFlowProvider>();
    final theme = Theme.of(context);
// -----------------------------------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (flow.isEmailVerified) {
        Navigator.pushReplacementNamed(
          context,
          '/email-verified-success',
        );
      }
    });
// -----------------------------------------------------------------------------
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
// -----------------------------------------------------------------------------
              const SizedBox(height: 100),
// -----------------------------------------------------------------------------
              const Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: MailSendRive(),
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'تحقق من بريدك الالكتروني',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 30),
              ),

              const SizedBox(height: 16),

              Text(
// -----------------------------------------------------------------------------
                ' أرسلنا رابط التحقق إلى ${flow.email}\nاضغط على الرابط لإكمال التحقق',
// -----------------------------------------------------------------------------
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),

              const SizedBox(height: 18),
// -----------------------------------------------------------------------------
              Text(
                  'لم يصلك البريد؟',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
              ),
// -----------------------------------------------------------------------------              

              const SizedBox(height: 14),
// -----------------------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: flow.canResend ? flow.resendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: flow.canResend
                        ? theme.colorScheme.primary
                        : theme.disabledColor.withOpacity(0.4),
                  ),
                  child: Text(
                    flow.canResend
                        ? 'إعادة إرسال'
                        : 'إعادة الإرسال بعد ${flow.secondsRemaining} ثانية',
                  ),
                ),
              ),
// -----------------------------------------------------------------------------
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
