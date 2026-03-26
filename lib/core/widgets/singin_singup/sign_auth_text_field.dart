import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SignAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  final String? errorText;
  final bool isPassword;
  final bool enableToggle;
  final String? externalError;

  const SignAuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.errorText,
    this.isPassword = false,
    this.enableToggle = false,
    this.externalError,
  });

  @override
  State<SignAuthTextField> createState() => _SignAuthTextFieldState();
}

class _SignAuthTextFieldState extends State<SignAuthTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = const InputDecoration().applyDefaults(theme.inputDecorationTheme);

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final effectiveError = (widget.errorText != null && widget.errorText!.isNotEmpty)
        ? widget.errorText
        : widget.externalError;
    final invalid = effectiveError?.isNotEmpty == true;

    return Column(
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: widget.onChanged,
          decoration: base.copyWith(
            hintText: widget.hint,
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
            suffixIconConstraints: const BoxConstraints(
              minHeight: 40,
              minWidth: 40,
            ),
            suffixIcon: widget.enableToggle
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color:
                          _obscure ? AppColors.fieldBorder : AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
          ),
        ),
        if (invalid) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                effectiveError!,
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
