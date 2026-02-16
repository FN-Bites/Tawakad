import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  final VoidCallback? onBack;
  final String title;
  final Widget child;

  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  final String bottomPrefixText; // "لديك حساب؟ "
  final String bottomActionText; // "قم بتسجيل الدخول"
  final VoidCallback? onBottomActionPressed;

  final Widget? mascot;

  const AuthScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    required this.title,
    required this.child,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    required this.bottomPrefixText,
    required this.bottomActionText,
    this.onBottomActionPressed,
    this.mascot,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSteps <= 0 ? 0.0 : (currentStep / totalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: const Offset(0, 5),
                        child: SizedBox(
                          width: 210,
                          height: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.progressBackground,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: onBack ?? () => Navigator.maybePop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: AppColors.icon,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _arabicProgressText(currentStep, totalSteps),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                height: 150,
                child: OverflowBox(
                  maxWidth: 180,
                  maxHeight: 240,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 160,
                    height: 240,
                    child: mascot ?? const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPrimaryPressed,
                  child: Text(
                    primaryButtonText,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 28.5),
              RichText(
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: bottomPrefixText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.linkSoft,
                          ),
                    ),
                    TextSpan(
                      text: bottomActionText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = onBottomActionPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _arabicProgressText(int current, int total) {
    return 'سؤال ${_toArabicIndic(current)} من ${_toArabicIndic(total)}';
  }

  String _toArabicIndic(int n) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = n.toString();
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final digit = int.tryParse(ch);
      buf.write(digit == null ? ch : map[digit]);
    }
    return buf.toString();
  }
}
