// ⚙️ settings_page.dart — شاشة الإعدادات (حفظ، خروج، أدوية)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/routes.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings/profile_labels.dart';
import 'package:tawakad_app/features/settings/ui/pages/medication_page.dart';
import 'package:tawakad_app/features/settings/ui/pages/notifications_settings_page.dart';
import 'package:tawakad_app/features/settings/ui/pages/privacy_policy_page.dart';
import 'package:tawakad_app/features/settings/ui/widgets/personal_info_sheets.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>();
      if (profile.profile == null && !profile.isLoading) {
        profile.load();
      }
    });
  }

  Future<void> _save() async {
    final profile = context.read<ProfileProvider>();
    final ok = await profile.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'تم حفظ التغييرات' : 'فشل حفظ التغييرات')),
    );
  }

  Future<void> _editPersonalInfo(Future<bool> Function() edit) async {
    final profile = context.read<ProfileProvider>();
    final ok = await edit();
    if (!mounted) return;
    final message =
        ok ? 'تم حفظ التعديل' : (profile.error ?? 'فشل حفظ التعديل');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _editEmail() async {
    final profile = context.read<ProfileProvider>();
    final ok = await showEditEmailSheet(context);
    if (!mounted) return;
    final message = ok
        ? 'تم إرسال رابط التحقق إلى البريد الجديد'
        : (profile.error ?? 'فشل تحديث البريد');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signOut() async {
    await context.read<ProfileProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: profile.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    children: [
                      const SettingsPageHeader(title: 'الإعدادات'),
                      const SizedBox(height: 26),
                      const SettingsSectionTitle(title: 'معلومات شخصية'),
                      SettingsCard(
                        children: [
                          SettingsNavigationTile(
                            title: 'اسم المستخدم',
                            subtitle: profile.profile?.displayName,
                            onTap: () => _editPersonalInfo(
                              () => showEditDisplayNameSheet(context),
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'تغيير البريد الإلكتروني',
                            subtitle: profile.profile?.email,
                            onTap: _editEmail,
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'تغيير كلمة المرور',
                            onTap: () => _editPersonalInfo(
                              () => showChangePasswordSheet(context),
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'الجنس',
                            subtitle: profileGenderLabel(profile.gender),
                            onTap: () => _editPersonalInfo(
                              () => showEditGenderSheet(context),
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'الحالة المستخدم',
                            subtitle: profileStatusLabel(profile.status),
                            onTap: () => _editPersonalInfo(
                              () => showEditStatusSheet(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SettingsSectionTitle(title: 'الدواء'),
                      SettingsCard(
                        children: [
                          SettingsNavigationTile(
                            title: 'إدارة الأدوية',
                            subtitle: 'إضافة وتنظيم الأدوية',
                            icon: Icons.medication_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const MedicationPage(),
                                ),
                              );
                            },
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'أوقات التناول',
                            subtitle: 'إدارة أوقات الأدوية',
                            onTap: () {},
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'التذكيرات',
                            subtitle: 'تنبيهات تناول الدواء',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SettingsSectionTitle(title: 'عام'),
                      SettingsCard(
                        children: [
                          const SettingsLanguageTile(),
                          const SettingsDivider(),
                          SettingsSwitchTile(
                            title: 'مظهر داكن',
                            value: profile.darkMode,
                            onChanged: profile.setDarkMode,
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'الإشعارات',
                            subtitle: profile.notificationsEnabled
                                ? 'مفعّلة'
                                : 'غير مفعّلة',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const NotificationsSettingsPage(),
                                ),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SettingsSectionTitle(title: 'حول توكّد'),
                      SettingsCard(
                        children: [
                          SettingsNavigationTile(
                            title: 'كيف تستخدم توكّد؟',
                            onTap: () {},
                          ),
                          const SettingsDivider(),
                          SettingsNavigationTile(
                            title: 'سياسة الخصوصية',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const PrivacyPolicyPage(),
                                ),
                              );
                            },
                          ),
                          const SettingsDivider(),
                          SettingsSwitchTile(
                            title: 'مشاركة البيانات',
                            value: profile.shareData,
                            onChanged: profile.setShareData,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SettingsActionButton(
                        text: profile.isSaving
                            ? 'جاري الحفظ...'
                            : 'حفظ التغييرات',
                        color: const Color(0xFF1F8EFA),
                        textColor: Colors.white,
                        onTap: profile.isSaving ? () {} : _save,
                      ),
                      const SizedBox(height: 14),
                      SettingsActionButton(
                        text: 'تسجيل خروج',
                        color: settingsCardColor(context),
                        textColor: Colors.red,
                        onTap: _signOut,
                      ),
                      const SizedBox(height: 14),
                      SettingsActionButton(
                        text: 'حذف الحساب',
                        color: settingsCardColor(context),
                        textColor: Colors.red,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
