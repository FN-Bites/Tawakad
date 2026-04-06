import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';
import 'day_of_week_selector.dart';

class DateTimeCard extends StatefulWidget {
  const DateTimeCard({super.key});

  @override
  State<DateTimeCard> createState() => DateTimeCardState();
}

class DateTimeCardState extends State<DateTimeCard> {
  bool _dateEnabled = false;
  bool _timeEnabled = false;
  bool _repeatEnabled = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<int> _selectedDays = [];

  DateTime? get selectedDate => _dateEnabled ? _selectedDate : null;

  TimeOfDay? get selectedTime => _timeEnabled ? _selectedTime : null;

  bool get repeatEnabled => _repeatEnabled;

  List<int> get selectedDays =>
      _repeatEnabled ? List<int>.unmodifiable(_selectedDays) : [];

  String _repeatSubtitle() {
    if (_selectedDays.isEmpty || _selectedDays.length == 7) return 'كل يوم';
    const names = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    final sorted = List<int>.from(_selectedDays)..sort();
    return sorted.map((i) => names[i]).join('، ');
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${weekdays[date.weekday - 1]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _onDateToggled(bool value) async {
    setState(() => _dateEnabled = value);
    if (!value) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _onTimeToggled(bool value) async {
    setState(() => _timeEnabled = value);
    if (!value) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onRepeatToggled(bool value) {
    setState(() {
      _repeatEnabled = value;
      if (!value) _selectedDays = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ToggleRowWidget(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: _dateEnabled,
            onChanged: _onDateToggled,
            subtitle: _dateEnabled && _selectedDate != null
                ? _formatDate(_selectedDate!)
                : null,
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F3)),
          ToggleRowWidget(
            icon: Icons.access_time_rounded,
            label: 'الوقت',
            value: _timeEnabled,
            onChanged: _onTimeToggled,
            subtitle: _timeEnabled && _selectedTime != null
                ? _selectedTime!.format(context)
                : null,
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F3)),
          ToggleRowWidget(
            icon: Icons.repeat_rounded,
            label: 'التكرار',
            value: _repeatEnabled,
            onChanged: _onRepeatToggled,
            subtitle: _repeatEnabled ? _repeatSubtitle() : null,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _repeatEnabled
                ? Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFF0F0F3)),
                      const SizedBox(height: 8),
                      DayOfWeekSelector(
                        selectedDays: _selectedDays,
                        onChanged: (days) =>
                            setState(() => _selectedDays = days),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
