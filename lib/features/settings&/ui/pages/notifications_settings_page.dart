// 🔔 notifications_settings_page.dart — تفعيل إشعارات التطبيق

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/services/notification_settings_service.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings&/providers/profile_provider.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/settings_ui.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final NotificationSettingsService _service = NotificationSettingsService();

  NotificationPreferenceState? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final state = await _service.loadState();
    if (!mounted) return;
    setState(() {
      _state = state;
      _loading = false;
    });
    context.read<ProfileProvider>().setNotificationsEnabled(state.appEnabled);
  }

  Future<void> _onAppNotificationsChanged(bool value) async {
    if (value) {
      final status = await _service.requestSystemPermission();
      if (!mounted) return;

      if (status.isGranted || status.isLimited) {
        await _service.setAppEnabled(true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تفعيل إشعارات التطبيق')),
        );
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فعّل الإشعارات من إعدادات الجهاز'),
          ),
        );
        await _service.openSystemSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم منح صلاحية الإشعارات')),
        );
      }
    } else {
      await _service.setAppEnabled(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إيقاف الإشعارات داخل التطبيق. لإيقافها من النظام افتح إعدادات الجهاز.',
          ),
        ),
      );
    }
    await _refresh();
  }

  Future<void> _setCategory(
    Future<void> Function(bool) setter,
    bool value,
  ) async {
    if (_state?.appEnabled != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فعّل إشعارات التطبيق أولاً')),
      );
      return;
    }
    await setter(value);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: SettingsPageHeader(title: 'الإشعارات'),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _StatusBanner(
                              label: _state?.statusLabel ?? '',
                              isActive: _state?.appEnabled == true,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
                            const SettingsSectionTitle(
                              title: 'إشعارات التطبيق',
                            ),
                            SettingsCard(
                              children: [
                                SettingsSwitchTile(
                                  title: 'تفعيل إشعارات التطبيق',
                                  value: _state?.appEnabled == true,
                                  onChanged: _onAppNotificationsChanged,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لتصلك التذكيرات، اسمح للتطبيق بإرسال الإشعارات من نظام '
                              'التشغيل ثم فعّل الخيار أعلاه.',
                              style: SettingsTextStyles.tileSubtitleStyle(
                                context,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SettingsSectionTitle(title: 'أنواع التنبيهات'),
                            SettingsCard(
                              children: [
                                SettingsSwitchTile(
                                  title: 'تذكيرات الأدوية',
                                  value: _state?.medicationEnabled == true,
                                  onChanged: (v) => _setCategory(
                                    _service.setMedicationEnabled,
                                    v,
                                  ),
                                ),
                                const SettingsDivider(),
                                SettingsSwitchTile(
                                  title: 'تذكيرات القوائم',
                                  value: _state?.listsEnabled == true,
                                  onChanged: (v) => _setCategory(
                                    _service.setListsEnabled,
                                    v,
                                  ),
                                ),
                                const SettingsDivider(),
                                SettingsSwitchTile(
                                  title: 'التذكيرات والمواعيد',
                                  value: _state?.remindersEnabled == true,
                                  onChanged: (v) => _setCategory(
                                    _service.setRemindersEnabled,
                                    v,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            SettingsActionButton(
                              text: 'فتح إعدادات الجهاز',
                              color: settingsCardColor(context),
                              textColor: isDark
                                  ? AppDarkColors.textPrimary
                                  : AppColors.textPrimary,
                              onTap: () async {
                                await _service.openSystemSettings();
                                await _refresh();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  final String label;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1F8EFA) : const Color(0xFF8A8A8E);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isActive
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الإشعارات',
                  style: SettingsTextStyles.tileTitleStyle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: SettingsTextStyles.tileSubtitleStyle(context)
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
