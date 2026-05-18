// 🧩 settings_ui.dart — ويدجت مشتركة (بطاقات، صفوف، أزرار، لغة)

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import 'package:tawakad_app/features/settings&/profile_labels.dart';

bool settingsIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color settingsPageBackground(BuildContext context) =>
    settingsIsDark(context) ? AppDarkColors.background : const Color(0xFFF1F4F8);

Color settingsCardColor(BuildContext context) =>
    settingsIsDark(context) ? AppDarkColors.card : Colors.white;

Color _settingsMutedText(BuildContext context) =>
    settingsIsDark(context) ? AppDarkColors.placeholder : const Color(0xFF8A8A8E);

Color _settingsPrimaryText(BuildContext context) =>
    settingsIsDark(context) ? AppDarkColors.textPrimary : AppColors.textPrimary;

/// أحجام خط موحّدة لشاشة الإعدادات وما يشابهها.
abstract final class SettingsTextStyles {
  static const String _fontFamily = 'Montserrat';

  static const double pageTitle = 22;
  static const double sectionTitle = 13;
  static const double tileTitle = 16;
  static const double tileSubtitle = 14;
  static const double actionButton = 16;

  static TextStyle pageTitleStyle(BuildContext context) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: pageTitle,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: _settingsPrimaryText(context),
      );

  static TextStyle sectionTitleStyle(BuildContext context) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: sectionTitle,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.2,
        color: _settingsMutedText(context),
      );

  static TextStyle tileTitleStyle(BuildContext context) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: tileTitle,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: _settingsPrimaryText(context),
      );

  static TextStyle tileSubtitleStyle(BuildContext context) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: tileSubtitle,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: _settingsMutedText(context),
      );

  static TextStyle tileSubtitleEmphasisStyle(BuildContext context) =>
      tileSubtitleStyle(context).copyWith(
        fontWeight: FontWeight.w600,
        color: _settingsPrimaryText(context),
      );

  static TextStyle actionButtonStyle(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: actionButton,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color,
      );
}

class SettingsCircleButton extends StatelessWidget {
  const SettingsCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppDarkColors.surface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppDarkColors.icon : const Color(0xFF4A4A4A),
        ),
      ),
    );
  }
}

class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    required this.title,
    this.action,
    this.trailing,
  });

  final String title;

  /// زر أو عنصر على **اليسار** (مثل الإعدادات أو إضافة دواء).
  final Widget? action;

  @Deprecated('Use action instead')
  final Widget? trailing;

  Widget? get _endAction => action ?? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        const GlassBackButton(),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: SettingsTextStyles.pageTitleStyle(context),
          ),
        ),
        _endAction ?? const SizedBox(width: 44),
      ],
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: SettingsTextStyles.sectionTitleStyle(context),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Container(
      decoration: BoxDecoration(
        color: settingsCardColor(context),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class SettingsNavigationTile extends StatelessWidget {
  const SettingsNavigationTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: icon != null
          ? Icon(icon, color: const Color(0xFF1F8EFA))
          : null,
      title: Text(
        title,
        style: SettingsTextStyles.tileTitleStyle(context),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: SettingsTextStyles.tileSubtitleStyle(context),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Color(0xFFB0B0B0),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: SettingsTextStyles.tileTitleStyle(context),
      ),
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF1F8EFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class SettingsLanguageTile extends StatelessWidget {
  const SettingsLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(
        'لغة التطبيق',
        style: SettingsTextStyles.tileTitleStyle(context),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              profileActiveLanguageLabel,
              style: SettingsTextStyles.tileSubtitleEmphasisStyle(context),
            ),
            const SizedBox(height: 2),
            Text(
              profileEnglishComingSoonLabel,
              style: SettingsTextStyles.tileSubtitleStyle(context),
            ),
          ],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Color(0xFFB0B0B0),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الإنجليزية ستُضاف قريباً')),
        );
      },
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.grey.withValues(alpha: 0.12),
    );
  }
}

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: SettingsTextStyles.actionButtonStyle(textColor),
          ),
        ),
      ),
    );
  }
}

class SettingsFormCard extends StatelessWidget {
  const SettingsFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: settingsCardColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
