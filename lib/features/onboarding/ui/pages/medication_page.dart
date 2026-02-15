import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../widgets/radio_option.dart';
import '../../../../core/theme/app_colors.dart';

class MedicationStepContent extends StatelessWidget {
  const MedicationStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return Column(
      children: [
        RadioOption(
          label: 'نعم',
          value: 'yes',
          groupValue: flow.takesMedication,
          onChanged: flow.setTakesMedication,
          hasError: flow.medicationInvalid,
        ),
        const SizedBox(height: 16),
        RadioOption(
          label: 'لا',
          value: 'no',
          groupValue: flow.takesMedication,
          onChanged: flow.setTakesMedication,
          hasError: flow.medicationInvalid,
        ),
        if (flow.medicationInvalid) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'يرجى اختيار إذا كنت تتناول أدوية',
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
