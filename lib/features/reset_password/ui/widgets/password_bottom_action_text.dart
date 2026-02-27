import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PasswordBottomActionText extends StatelessWidget {
  const PasswordBottomActionText({
    super.key,
    required this.actionText,
    this.onTap,
  });

  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.left,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        text: actionText,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
        recognizer: TapGestureRecognizer()..onTap = onTap,
      ),
    );
  }
}
