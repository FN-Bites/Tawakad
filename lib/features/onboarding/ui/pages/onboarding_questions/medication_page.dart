import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/onboarding/providers/onboarding_flow_provider.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/radio_option.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class MedicationStepContent extends StatelessWidget {
  const MedicationStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return FieldCard(
      children: [
        RadioOption(
          label: 'نعم',
          value: 'yes',
          groupValue: flow.takesMedication,
          onChanged: (v) {
            flow.setTakesMedication(v);
            flow.clearMascotError();
          },
          hasError: flow.medicationInvalid,
        ),
        RadioOption(
          label: 'لا',
          value: 'no',
          groupValue: flow.takesMedication,
          onChanged: (v) {
            flow.setTakesMedication(v);
            flow.clearMascotError();
          },
          hasError: flow.medicationInvalid,
        ),
        if (flow.medicationInvalid) ...[
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
