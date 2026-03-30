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
    final isDark = theme.brightness == Brightness.dark;
    final base =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);

    final fillColor = invalid
        ? (isDark
            ? AppColors.fieldErrorFill.withOpacity(0.15)
            : AppColors.fieldErrorFill)
        : (isDark ? AppDarkColors.surface : AppColors.surface);

    final borderColor = invalid
        ? AppColors.fieldErrorBorder
        : (isDark ? AppDarkColors.fieldBorder : AppColors.fieldBorder);

    final focusedColor =
        invalid ? AppColors.fieldErrorBorder : AppColors.primary;

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
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? AppDarkColors.textPrimary : AppColors.textPrimary,
          ),
          onChanged: (v) {
            onChanged(v);
            onAnyChange?.call();
          },
          decoration: base.copyWith(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            errorText: null,
            fillColor: fillColor,
            enabledBorder:
                (base.enabledBorder as OutlineInputBorder?)?.copyWith(
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ) ??
                    border(borderColor, 1),
            focusedBorder:
                (base.focusedBorder as OutlineInputBorder?)?.copyWith(
                      borderSide: BorderSide(color: focusedColor, width: 1.5),
                    ) ??
                    border(focusedColor, 1.5),
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
