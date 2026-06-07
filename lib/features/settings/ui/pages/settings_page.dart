import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/routes.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/features/settings/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings/profile_labels.dart';
import 'package:tawakad_app/features/settings/ui/pages/medication_page.dart';
import 'package:tawakad_app/core/services/notification_settings_service.dart';
import 'package:tawakad_app/features/settings/ui/pages/privacy_policy_page.dart';
import 'package:tawakad_app/features/settings/ui/widgets/personal_info_sheets.dart';
import 'package:tawakad_app/features/settings/ui/widgets/settings_ui.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';

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

  Future<void> _onNotificationsChanged(bool value) async {
    final profile = context.read<ProfileProvider>();
    profile.setNotificationsEnabled(value);
    await NotificationSettingsService().setAppEnabled(value);
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      const SettingsPageHeader(title: 'الإعدادات'),
                      const SizedBox(height: 26),

                      // ── Personal info ────────────────────────────────────
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

                      // ── Medication ───────────────────────────────────────
                      const SettingsSectionTitle(title: 'الدواء'),
                      SettingsCard(
                        children: [
                          SettingsNavigationTile(
                            title: 'إدارة الأدوية',
                            subtitle: 'إضافة وتنظيم الأدوية',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const MedicationPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── General ──────────────────────────────────────────
                      const SettingsSectionTitle(title: 'عام'),
                      SettingsCard(
                        children: [
                          const SettingsLanguageTile(),
                          const SettingsDivider(),
                          ToggleRowWidget(
                            label: 'مظهر داكن',
                            value: profile.darkMode,
                            onChanged: profile.setDarkMode,
                          ),
                          ToggleRowWidget(
                            label: 'الإشعارات',
                            value: profile.notificationsEnabled,
                            onChanged: (v) async {
                              await _onNotificationsChanged(v);
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
                        ],
                      ),
                      const SizedBox(height: 28),

                      AppLiquidButtons.primary(
                        label: profile.isSaving
                            ? 'جاري الحفظ...'
                            : 'حفظ التغييرات',
                        onPressed: profile.isSaving ? null : _save,
                      ),
                      const SizedBox(height: 12),

                      AppLiquidButtons.iconWithLabel(
                        icon: Icons.logout_rounded,
                        label: 'تسجيل خروج',
                        onPressed: _signOut,
                        iconColor: Colors.red,
                        textStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppLiquidButtons.iconWithLabel(
                        icon: Icons.delete_outline_rounded,
                        label: 'حذف الحساب',
                        onPressed: () {},
                        iconColor: Colors.red,
                        textStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
