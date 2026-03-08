import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EntryHeader extends StatelessWidget {
  const EntryHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onBack ?? () => Navigator.maybePop(context),
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: AppColors.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
