import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/onboarding/state/onboarding_flow_provider.dart';
import 'package:tawakad_app/core/widgets/auth_text_field.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class NameStepContent extends StatelessWidget {
  const NameStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return FieldCard(
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
