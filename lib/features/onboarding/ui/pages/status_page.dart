import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../widgets/radio_option.dart';
import '../../../../core/theme/app_colors.dart';

class StatusStepContent extends StatelessWidget {
  const StatusStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    return Column(
      children: [
        RadioOption(
          label: 'طالب',
          value: 'student',
          groupValue: flow.status,
          onChanged: flow.setStatus,
          hasError: flow.statusInvalid,
        ),
        const SizedBox(height: 16),
        RadioOption(
          label: 'موظف',
          value: 'employee',
          groupValue: flow.status,
          onChanged: flow.setStatus,
          hasError: flow.statusInvalid,
        ),
        const SizedBox(height: 16),
        RadioOption(
          label: 'متفرغ',
          value: 'free',
          groupValue: flow.status,
          onChanged: flow.setStatus,
          hasError: flow.statusInvalid,
        ),
        const SizedBox(height: 16),
        RadioOption(
          label: 'أخرى',
          value: 'other',
          groupValue: flow.status,
          onChanged: flow.setStatus,
          hasError: flow.statusInvalid,
        ),
        if (flow.statusInvalid) ...[
          const SizedBox(height: 8),
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
