import 'package:flutter/material.dart';
import '../../../../core/widgets/entry_header.dart';
import '../../../../core/routes.dart';
import '../../../../core/widgets/animation/mail_sent_rive.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({
    super.key,
    this.emailMasked = 'st******@gmail.com',
  });

  final String emailMasked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              EntryHeader(
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.signup,
                ),
              ),
              const SizedBox(height: 70),
              const SizedBox(
                width: 130,
                height: 130,
                child: MailSendRive(),
              ),
              const SizedBox(height: 36),
              Text(
                'تحقق من بريدك الالكتروني',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ' $emailMasked أرسلنا رابط التحقق إلى \nاضغط على الرابط لإكمال التحقق',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {},
                child: Text(
                  'لم يصلك البريد؟',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.emailVerifiedSuccess,
                    );
                  },
                  child: const Text('إعادة إرسال'),
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
