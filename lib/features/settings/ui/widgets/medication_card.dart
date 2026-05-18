// 💊 medication_card.dart — بطاقة دواء في قائمة الأدوية

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.name,
    required this.intakeTimes,
    required this.autoAdd,
    this.onTap,
  });

  final String name;
  final List<String> intakeTimes;
  final bool autoAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: settingsCardColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1F8EFA).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Color(0xFF1F8EFA),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: SettingsTextStyles.tileTitleStyle(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: intakeTimes
                        .map(
                          (time) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F8EFA)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              time,
                              style: SettingsTextStyles.tileSubtitleStyle(
                                context,
                              ).copyWith(
                                color: isDark
                                    ? AppDarkColors.textPrimary
                                    : const Color(0xFF4A4A4A),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        autoAdd
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 18,
                        color: autoAdd ? Colors.green : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        autoAdd ? 'إضافة تلقائية للقوائم' : 'إضافة يدوية',
                        style: SettingsTextStyles.tileSubtitleStyle(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFFB0B0B0),
            ),
          ],
        ),
      ),
    );
  }
}
