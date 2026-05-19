import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
                child: Divider(thickness: 1, color: Color(0xFFBDBDBD))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'أو',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppDarkColors.placeholder
                      : AppColors.placeholder,
                ),
              ),
            ),
            const Expanded(
                child: Divider(thickness: 1, color: Color(0xFFBDBDBD))),
          ],
        ),
        const SizedBox(height: 20),
        AppLiquidButtons.custom(
          height: 50,
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تسجيل الدخول بإستخدام Google',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppDarkColors.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Image.asset('assets/icons/Google.png', height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
