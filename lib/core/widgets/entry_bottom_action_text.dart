import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EntryBottomActionText extends StatelessWidget {
  const EntryBottomActionText({
    super.key,
    required this.prefixText,
    required this.actionText,
    this.onTap,
  });

  final String prefixText;
  final String actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          TextSpan(
            text: prefixText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.linkSoft,
                ),
          ),
          TextSpan(
            text: actionText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
