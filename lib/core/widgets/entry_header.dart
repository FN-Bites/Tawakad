import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EntryHeader extends StatelessWidget {
  const EntryHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onBack ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(24),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: AppColors.icon,
            ),
          ),
        ),
      ),
    );
  }
}
