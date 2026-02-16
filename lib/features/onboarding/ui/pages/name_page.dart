import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_flow_provider.dart';
import '../../../../core/theme/app_colors.dart';

class NameStepContent extends StatelessWidget {
  const NameStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingFlowProvider>();

    Widget field({
      required TextEditingController controller,
      required String hint,
      required ValueChanged<String> onChanged,
      required bool invalid,
      required String errorMsg,
    }) {
      final theme = Theme.of(context);
      final base =
          const InputDecoration().applyDefaults(theme.inputDecorationTheme);

      return Column(
        children: [
          TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.name,
            onChanged: (v) {
              onChanged(v);
              flow.clearMascotError();
            },
            decoration: base.copyWith(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              errorText: null,
              fillColor: invalid ? AppColors.fieldErrorFill : AppColors.surface,
              enabledBorder:
                  (base.enabledBorder as OutlineInputBorder?)?.copyWith(
                        borderSide: BorderSide(
                          color: invalid
                              ? AppColors.fieldErrorBorder
                              : AppColors.fieldBorder,
                          width: 1,
                        ),
                      ) ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: invalid
                              ? AppColors.fieldErrorBorder
                              : AppColors.fieldBorder,
                          width: 1,
                        ),
                      ),
              focusedBorder:
                  (base.focusedBorder as OutlineInputBorder?)?.copyWith(
                        borderSide: BorderSide(
                          color: invalid
                              ? AppColors.fieldErrorBorder
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ) ??
                      OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: invalid
                              ? AppColors.fieldErrorBorder
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
            ),
          ),
          if (invalid) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  errorMsg,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: theme.inputDecorationTheme.errorStyle ??
                      theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.fieldErrorBorder,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        field(
          controller: flow.firstNameController,
          hint: 'الاسم الأول',
          onChanged: flow.setFirstName,
          invalid: flow.firstNameInvalid,
          errorMsg: 'يرجى إدخال الاسم الأول',
        ),
        const SizedBox(height: 16),
        field(
          controller: flow.lastNameController,
          hint: 'الاسم الأخير',
          onChanged: flow.setLastName,
          invalid: flow.lastNameInvalid,
          errorMsg: 'يرجى إدخال الاسم الأخير',
        ),
      ],
    );
  }
}
