import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../widgets/onboarding_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class NamePage extends StatelessWidget {
  const NamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return AuthScaffold(
      currentStep: flow.currentStep,
      totalSteps: flow.totalSteps,
      title: 'ماهو اسمك؟',
      primaryButtonText: 'التالي',
      onPrimaryPressed: flow.nextFromNameStep,
      onBack: flow.back,
      bottomPrefixText: 'لديك حساب؟ ',
      bottomActionText: 'قم بتسجيل الدخول',
      onBottomActionPressed: () {},
      child: Directionality(
        textDirection:
            TextDirection.rtl, // ✅ makes errorText render RTL (right side)
        child: Column(
          children: [
            TextField(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.name,
              onChanged: flow.setFirstName,
              decoration: InputDecoration(
                hintText: 'الاسم الأول',
                filled: true,
                fillColor: flow.firstNameInvalid
                    ? AppColors.fieldErrorFill
                    : AppColors.surface,
                errorText:
                    flow.firstNameInvalid ? 'يرجى إدخال الاسم الأول' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.name,
              onChanged: flow.setLastName,
              decoration: InputDecoration(
                hintText: 'الاسم الأخير',
                filled: true,
                fillColor: flow.lastNameInvalid
                    ? AppColors.fieldErrorFill
                    : AppColors.surface,
                errorText:
                    flow.lastNameInvalid ? 'يرجى إدخال الاسم الأخير' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
