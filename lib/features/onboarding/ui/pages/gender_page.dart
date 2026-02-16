import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../widgets/radio_option.dart';
import '../../../../core/theme/app_colors.dart';

class GenderStepContent extends StatelessWidget {
  const GenderStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return Column(
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
        const SizedBox(height: 16),
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
        if (flow.genderInvalid) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
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
      ],
    );
  }
}
