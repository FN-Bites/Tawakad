import 'package:flutter/material.dart';

class PasswordStrengthHints extends StatelessWidget {
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasMinLength;
  final bool hasSpecialChar;
  final bool hasLowercase;
// -----------------------------------------------------------------------------
  final bool isPasswordEmpty;
// -----------------------------------------------------------------------------


  const PasswordStrengthHints({
    super.key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasSpecialChar,
// -----------------------------------------------------------------------------
    required this.isPasswordEmpty,
// -----------------------------------------------------------------------------
  });
// -----------------------------------------------------------------------------
  Widget _buildRow(String text, bool ok) {
    Color color;
    IconData icon;

    if (isPasswordEmpty) {
      color = const Color(0xFF9E9E9E); // رمادي
      icon = Icons.remove_circle_outline;
    } else if (ok) {
      color = const Color(0xFF27AE60); // أخضر
      icon = Icons.check_circle;
    } else {
      color = const Color(0xFFEB5757); // أحمر
      icon = Icons.cancel;
    }

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
// -----------------------------------------------------------------------------
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