import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../../../../core/widgets/auth_text_field.dart';

class NameStepContent extends StatelessWidget {
  const NameStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return Column(
      children: [
        AuthTextField(
          controller: flow.firstNameController,
          hint: 'الاسم الأول',
          keyboardType: TextInputType.name,
          onChanged: flow.setFirstName,
          invalid: flow.firstNameInvalid,
          errorMsg: 'يرجى إدخال الاسم الأول',
          onAnyChange: flow.clearMascotError,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: flow.lastNameController,
          hint: 'الاسم الأخير',
          keyboardType: TextInputType.name,
          onChanged: flow.setLastName,
          invalid: flow.lastNameInvalid,
          errorMsg: 'يرجى إدخال الاسم الأخير',
          onAnyChange: flow.clearMascotError,
        ),
      ],
    );
  }
}
