// 👤 profile_header_card.dart — بطاقة الصورة والاسم والبريد والرتبة

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/settings_ui.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.email,
    this.rankLabel = 'مستكشف محترف',
  });

  final String displayName;
  final String email;
  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: settingsCardColor(context),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF63B3FF), Color(0xFF5B6CFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF63B3FF).withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: SettingsTextStyles.pageTitleStyle(context),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: SettingsTextStyles.tileSubtitleStyle(context),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E72FF), Color(0xFF55C7FF)],
              ),
            ),
            child: Text(
              rankLabel,
              style: SettingsTextStyles.actionButtonStyle(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
