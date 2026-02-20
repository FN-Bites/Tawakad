import 'package:flutter/material.dart';
import '../../../../core/widgets/animation/shield_rive.dart';

class EmailVerifiedSuccessPage extends StatelessWidget {
  const EmailVerifiedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              const Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: ShieldRive(),
                ),
              ),

              const SizedBox(height: 36),
              Text(
                'تم تفعيل بريدك الالكتروني\nوإنشاء حسابك بنجاح',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle centered
              Text(
                'يمكنك البدء باستخدام التطبيق الآن',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
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
