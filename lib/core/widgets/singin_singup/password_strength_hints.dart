import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class PasswordStrengthHints extends StatelessWidget {
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasMinLength;
  final bool hasSpecialChar;
  final bool hasLowercase;

  const PasswordStrengthHints({
    super.key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasSpecialChar,
  });

  Widget _buildRow(String text, bool ok) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: text.isEmpty
              ? const Color(0x6A7282) // رمادي
              : ok
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFEB5757),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: text.isEmpty
                ? const Color(0x6A7282) // رمادي
                : ok
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFEB5757),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('لا تقل عن 8 أحرف', hasMinLength),
        const SizedBox(height: 2),
        _buildRow('تحتوي على رقم واحد على الأقل', hasNumber),
        const SizedBox(height: 2),
        _buildRow('تحتوي على حرف كبير واحد على الأقل', hasUppercase),
        const SizedBox(height: 2),
        _buildRow('تحتوي على حرف صغير واحد على الأقل', hasLowercase),
        const SizedBox(height: 2),
        _buildRow('تحتوي على رمز خاص واحد على الأقل', hasSpecialChar),
      ],
    );
  }
}
