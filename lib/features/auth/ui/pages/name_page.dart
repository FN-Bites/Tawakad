import 'package:flutter/material.dart';
import '../widgets/onboarding_scaffold.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      currentStep: 1,
      totalSteps: 4,
      title: 'ماهو اسمك؟',
      primaryButtonText: 'التالي',
      onPrimaryPressed: () {},
      bottomPrefixText: 'لديك حساب؟ ',
      bottomActionText: 'قم بتسجيل الدخول',
      onBottomActionPressed: () {},
      child: const Column(
        children: [
          TextField(decoration: InputDecoration(hintText: 'الإسم الأول')),
          SizedBox(height: 12),
          TextField(decoration: InputDecoration(hintText: 'الإسم الأخير')),
        ],
      ),
    );
  }
}
