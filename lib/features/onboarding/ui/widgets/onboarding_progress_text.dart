import 'package:flutter/material.dart';

class OnboardingProgressText extends StatelessWidget {
  const OnboardingProgressText({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Text(
      'سؤال ${_toArabicIndic(currentStep)} من ${_toArabicIndic(totalSteps)}',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
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
