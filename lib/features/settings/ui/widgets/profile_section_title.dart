// 📌 profile_section_title.dart — عنوان قسم في الملف الشخصي

import 'package:flutter/material.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: SettingsTextStyles.tileTitleStyle(context).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
