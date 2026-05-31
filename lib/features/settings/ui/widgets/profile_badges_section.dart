// 🏆 profile_badges_section.dart — شبكة الجوائز المفتوحة والمقفلة

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings/ui/widgets/profile_section_title.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({
    super.key,
    this.unlockedCount = 6,
    this.lockedCount = 3,
  });

  final int unlockedCount;
  final int lockedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: 'جوائزي'),
        const SizedBox(height: 18),
        _UnlockedBadgesGrid(count: unlockedCount),
        const SizedBox(height: 36),
        const ProfileSectionTitle(title: 'الجوائز المقفلة'),
        const SizedBox(height: 18),
        _LockedBadgesRow(count: lockedCount),
      ],
    );
  }
}

class _UnlockedBadgesGrid extends StatelessWidget {
  const _UnlockedBadgesGrid({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (_, index) {
        return ProfileBadgeTile(
          title: 'إنجاز ${index + 1}',
          icon: Icons.emoji_events_rounded,
          accentColor: const Color(0xFFFFB300),
        );
      },
    );
  }
}

class _LockedBadgesRow extends StatelessWidget {
  const _LockedBadgesRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        count,
        (_) => Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: isDark
                ? AppDarkColors.surface.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Color(0xFF9A9A9A),
            size: 34,
          ),
        ),
      ),
    );
  }
}

/// بطاقة جائزة واحدة في الشبكة.
class ProfileBadgeTile extends StatelessWidget {
  const ProfileBadgeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: settingsCardColor(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: accentColor),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: SettingsTextStyles.tileSubtitleStyle(context).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
