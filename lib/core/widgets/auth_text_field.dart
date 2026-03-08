import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.invalid,
    required this.errorMsg,
    this.keyboardType = TextInputType.text,
    this.onAnyChange,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  final bool invalid;
  final String errorMsg;

  final TextInputType keyboardType;

  final VoidCallback? onAnyChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      children: [
        TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          onChanged: (v) {
            onChanged(v);
            onAnyChange?.call();
          },
          decoration: base.copyWith(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            errorText: null,
            fillColor: invalid ? AppColors.fieldErrorFill : AppColors.surface,
            enabledBorder: (base.enabledBorder as OutlineInputBorder?)
                    ?.copyWith(
                  borderSide: BorderSide(
                    color: invalid
                        ? AppColors.fieldErrorBorder
                        : AppColors.fieldBorder,
                    width: 1,
                  ),
                ) ??
                border(
                  invalid ? AppColors.fieldErrorBorder : AppColors.fieldBorder,
                  1,
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
                    border(
                      invalid ? AppColors.fieldErrorBorder : AppColors.primary,
                      1.5,
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
}
