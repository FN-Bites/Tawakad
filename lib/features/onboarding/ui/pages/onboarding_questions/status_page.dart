import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/onboarding/providers/onboarding_flow_provider.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/radio_option.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';

class StatusStepContent extends StatelessWidget {
  const StatusStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    void select(String? v) {
      flow.setStatus(v);
      flow.clearMascotError();
    }

    return FieldCard(
      children: [
        RadioOption(
          label: 'طالب',
          value: 'student',
          groupValue: flow.status,
          onChanged: select,
          hasError: flow.statusInvalid,
        ),
        RadioOption(
          label: 'موظف',
          value: 'employee',
          groupValue: flow.status,
          onChanged: select,
          hasError: flow.statusInvalid,
        ),
        RadioOption(
          label: 'متفرغ',
          value: 'free',
          groupValue: flow.status,
          onChanged: select,
          hasError: flow.statusInvalid,
        ),
        RadioOption(
          label: 'أخرى',
          value: 'other',
          groupValue: flow.status,
          onChanged: select,
          hasError: flow.statusInvalid,
        ),
        if (flow.statusInvalid) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'يرجى اختيار الحالة',
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
