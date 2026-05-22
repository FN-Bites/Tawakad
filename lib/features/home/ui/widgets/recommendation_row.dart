import 'package:flutter/material.dart';
import 'package:tawakad_app/core/services/recommendation_service.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

class RecommendationRow extends StatelessWidget {
  final RecommendedItem item;
  final bool alreadyAdded;
  final bool isDark;
  final VoidCallback onAdd;

  const RecommendationRow({
    super.key,
    required this.item,
    required this.alreadyAdded,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppDarkColors.textPrimary : const Color(0xFF1C1C1E);
    final subColor =
        isDark ? AppDarkColors.placeholder : const Color(0xFF8A8A8E);
    final addedColor = isDark
        ? AppDarkColors.placeholder.withOpacity(0.4)
        : const Color(0xFFB2B2B8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: alreadyAdded
                  ? (isDark
                      ? AppDarkColors.fieldBorder
                      : const Color(0xFFEFEFF4))
                  : const Color(0xFF1F8EFA).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              alreadyAdded
                  ? Icons.check_rounded
                  : Icons.lightbulb_outline_rounded,
              size: 16,
              color: alreadyAdded ? addedColor : const Color(0xFF1F8EFA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.arabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: alreadyAdded ? addedColor : textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.english,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: alreadyAdded ? null : onAdd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: alreadyAdded
                    ? (isDark
                        ? AppDarkColors.fieldBorder
                        : const Color(0xFFEFEFF4))
                    : const Color(0xFF1F8EFA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                alreadyAdded ? Icons.check_rounded : Icons.add_rounded,
                size: 18,
                color: alreadyAdded ? addedColor : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
