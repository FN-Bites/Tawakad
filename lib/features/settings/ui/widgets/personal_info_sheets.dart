import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/onboarding/ui/widgets/radio_option.dart';
import 'package:tawakad_app/features/settings/profile_options.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

Future<bool> showEditDisplayNameSheet(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  final controller =
      TextEditingController(text: profile.usernameController.text);

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _SheetContainer(
            title: 'تعديل اسم المستخدم',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsFormCard(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: SettingsTextStyles.tileTitleStyle(sheetContext),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'الاسم الأول والأخير',
                      hintStyle:
                          SettingsTextStyles.tileSubtitleStyle(sheetContext),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SettingsActionButton(
                  text: 'حفظ',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('أدخل الاسم')),
                      );
                      return;
                    }
                    Navigator.pop(sheetContext, true);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (saved != true || !context.mounted) {
    controller.dispose();
    return false;
  }

  final name = controller.text.trim();
  controller.dispose();
  profile.usernameController.text = name;
  return profile.save();
}

Future<bool> showEditGenderSheet(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  String? selected = profile.gender;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: _SheetContainer(
              title: 'تعديل الجنس',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...profileGenderOptions.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RadioOption(
                        label: entry.value,
                        value: entry.key,
                        groupValue: selected,
                        onChanged: (v) => setSheetState(() => selected = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsActionButton(
                    text: 'حفظ',
                    color: AppColors.primary,
                    textColor: Colors.white,
                    onTap: () {
                      if (selected == null) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('اختر الجنس')),
                        );
                        return;
                      }
                      Navigator.pop(sheetContext, true);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (saved != true || !context.mounted || selected == null) return false;

  profile.setGender(selected);
  return profile.save();
}

Future<bool> showEditStatusSheet(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  String? selected = profile.status;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: _SheetContainer(
              title: 'تعديل الحالة',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...profileStatusOptions.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RadioOption(
                        label: entry.value,
                        value: entry.key,
                        groupValue: selected,
                        onChanged: (v) => setSheetState(() => selected = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsActionButton(
                    text: 'حفظ',
                    color: AppColors.primary,
                    textColor: Colors.white,
                    onTap: () {
                      if (selected == null) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('اختر الحالة')),
                        );
                        return;
                      }
                      Navigator.pop(sheetContext, true);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (saved != true || !context.mounted || selected == null) return false;

  profile.setStatus(selected);
  return profile.save();
}

Future<bool> showChangePasswordSheet(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _SheetContainer(
            title: 'تغيير كلمة المرور',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PasswordField(
                  controller: currentController,
                  hint: 'كلمة المرور الحالية',
                ),
                const SizedBox(height: 12),
                _PasswordField(
                  controller: newController,
                  hint: 'كلمة المرور الجديدة',
                ),
                const SizedBox(height: 12),
                _PasswordField(
                  controller: confirmController,
                  hint: 'تأكيد كلمة المرور الجديدة',
                ),
                const SizedBox(height: 8),
                Text(
                  '8 أحرف على الأقل',
                  style: SettingsTextStyles.tileSubtitleStyle(sheetContext),
                ),
                const SizedBox(height: 20),
                SettingsActionButton(
                  text: 'تحديث كلمة المرور',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () => Navigator.pop(sheetContext, true),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  final current = currentController.text;
  final newPassword = newController.text;
  final confirm = confirmController.text;
  currentController.dispose();
  newController.dispose();
  confirmController.dispose();

  if (saved != true || !context.mounted) return false;

  if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أكمل جميع الحقول')),
    );
    return false;
  }

  if (newPassword != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('كلمة المرور الجديدة غير متطابقة')),
    );
    return false;
  }

  return profile.updatePassword(
    currentPassword: current,
    newPassword: newPassword,
  );
}

Future<bool> showEditEmailSheet(BuildContext context) async {
  final profile = context.read<ProfileProvider>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _SheetContainer(
            title: 'تغيير البريد الإلكتروني',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'البريد الحالي: ${profile.profile?.email ?? ''}',
                  style: SettingsTextStyles.tileSubtitleStyle(sheetContext),
                ),
                const SizedBox(height: 14),
                SettingsFormCard(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: SettingsTextStyles.tileTitleStyle(sheetContext),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'البريد الجديد',
                      hintStyle:
                          SettingsTextStyles.tileSubtitleStyle(sheetContext),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SettingsFormCard(
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: SettingsTextStyles.tileTitleStyle(sheetContext),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'كلمة المرور الحالية للتأكيد',
                      hintStyle:
                          SettingsTextStyles.tileSubtitleStyle(sheetContext),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SettingsActionButton(
                  text: 'تحديث البريد',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () => Navigator.pop(sheetContext, true),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  final newEmail = emailController.text.trim();
  final password = passwordController.text;
  emailController.dispose();
  passwordController.dispose();

  if (saved != true || !context.mounted) return false;

  if (newEmail.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أدخل البريد وكلمة المرور')),
    );
    return false;
  }

  return profile.updateEmail(newEmail, password);
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SettingsFormCard(
      child: TextField(
        controller: controller,
        obscureText: true,
        style: SettingsTextStyles.tileTitleStyle(context),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: SettingsTextStyles.tileSubtitleStyle(context),
        ),
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: settingsCardColor(context),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: SettingsTextStyles.pageTitleStyle(context).copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
