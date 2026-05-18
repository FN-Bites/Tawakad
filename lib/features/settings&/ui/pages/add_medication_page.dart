// ➕ add_medication_page.dart — إضافة دواء جديد

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/settings_ui.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final TextEditingController _nameController = TextEditingController();

  final List<TimeOfDay> _intakeTimes = [];
  bool _autoAdd = true;
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _intakeTimes.isNotEmpty
          ? _intakeTimes.last
          : TimeOfDay.now(),
    );
    if (result == null) return;

    final duplicate = _intakeTimes.any(
      (t) => t.hour == result.hour && t.minute == result.minute,
    );
    if (duplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا الوقت مضاف مسبقاً')),
      );
      return;
    }

    setState(() {
      _intakeTimes.add(result);
      _intakeTimes.sort((a, b) {
        final aMin = a.hour * 60 + a.minute;
        final bMin = b.hour * 60 + b.minute;
        return aMin.compareTo(bMin);
      });
    });
  }

  void _removeTime(int index) {
    setState(() => _intakeTimes.removeAt(index));
  }

  String _formatTime(TimeOfDay time) => time.format(context);

  @override
  Widget build(BuildContext context) {
    final isDark = settingsIsDark(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SettingsPageHeader(title: 'إضافة دواء'),
                const SizedBox(height: 28),
                _sectionLabel(context, 'اسم الدواء'),
                SettingsFormCard(
                  child: TextField(
                    controller: _nameController,
                    style: SettingsTextStyles.tileTitleStyle(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'أدخل اسم الدواء',
                      hintStyle: SettingsTextStyles.tileSubtitleStyle(context),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _sectionLabel(context, 'أوقات التناول'),
                if (_intakeTimes.isEmpty)
                  SettingsFormCard(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'لم تُضف أوقات بعد',
                      style: SettingsTextStyles.tileSubtitleStyle(context),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...List.generate(_intakeTimes.length, (index) {
                    final time = _intakeTimes[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _intakeTimes.length - 1 ? 10 : 0,
                      ),
                      child: SettingsFormCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.access_time_rounded,
                            color: isDark
                                ? AppDarkColors.icon
                                : AppColors.primary,
                          ),
                          title: Text(
                            _formatTime(time),
                            style: SettingsTextStyles.tileTitleStyle(context),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeTime(index),
                            tooltip: 'حذف الوقت',
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _addTime,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      'إضافة وقت',
                      style: SettingsTextStyles.tileSubtitleEmphasisStyle(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SettingsFormCard(
                  child: SettingsSwitchTile(
                    title: 'إضافة تلقائية للقوائم',
                    value: _autoAdd,
                    onChanged: (v) => setState(() => _autoAdd = v),
                  ),
                ),
                const SizedBox(height: 14),
                SettingsFormCard(
                  child: SettingsSwitchTile(
                    title: 'تفعيل التذكيرات',
                    value: _reminderEnabled,
                    onChanged: (v) => setState(() => _reminderEnabled = v),
                  ),
                ),
                const SizedBox(height: 32),
                SettingsActionButton(
                  text: 'حفظ الدواء',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('أدخل اسم الدواء')),
                      );
                      return;
                    }
                    if (_intakeTimes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('أضف وقت تناول واحداً على الأقل'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: SettingsTextStyles.sectionTitleStyle(context),
        ),
      ),
    );
  }
}
