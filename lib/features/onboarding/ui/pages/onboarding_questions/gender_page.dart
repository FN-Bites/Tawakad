import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/onboarding/state/onboarding_flow_provider.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/radio_option.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class GenderStepContent extends StatelessWidget {
  const GenderStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return FieldCard(
      gap: 12,
      children: [
        RadioOption(
          label: 'ذكر',
          value: 'male',
          groupValue: flow.gender,
          onChanged: (v) {
            flow.setGender(v);
            flow.clearMascotError();
          },
          hasError: flow.genderInvalid,
        ),
        RadioOption(
          label: 'أنثى',
          value: 'female',
          groupValue: flow.gender,
          onChanged: (v) {
            flow.setGender(v);
            flow.clearMascotError();
          },
          hasError: flow.genderInvalid,
        ),
        if (flow.genderInvalid)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'يرجى اختيار الجنس',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.fieldErrorBorder,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
