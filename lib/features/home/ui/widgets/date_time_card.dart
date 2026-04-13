import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';
import 'day_of_week_selector.dart';

class DateTimeCard extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialTime;
  final bool initialRepeat;
  final List<int> initialRepeatDays;

  const DateTimeCard({
    super.key,
    this.initialDate,
    this.initialTime,
    this.initialRepeat = false,
    this.initialRepeatDays = const [],
  });

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

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
      _dateEnabled = true;
    }

    if (widget.initialTime != null) {
      final parts = widget.initialTime!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
          _timeEnabled = true;
        }
      }
    }

    if (widget.initialRepeat) {
      _repeatEnabled = true;
      _selectedDays = List<int>.from(widget.initialRepeatDays);
    }
  }

  DateTime? get selectedDate => _dateEnabled ? _selectedDate : null;
  TimeOfDay? get selectedTime => _timeEnabled ? _selectedTime : null;
  bool get repeatEnabled => _repeatEnabled;
  List<int> get selectedDays =>
      _repeatEnabled ? List<int>.unmodifiable(_selectedDays) : [];

  String _toArabicNumerals(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], arabic[i]);
    }
    return input;
  }

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
    return '${weekdays[date.weekday - 1]}، ${_toArabicNumerals(date.day.toString())} ${months[date.month - 1]} ${_toArabicNumerals(date.year.toString())}';
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'ص' : 'م';
    return '${_toArabicNumerals(hour.toString())}:${_toArabicNumerals(m)} $period';
  }

  ThemeData _pickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF4CAF82),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.white,
        headerForegroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteColor: Color(0xFFF5F5F5),
        hourMinuteTextColor: Colors.black87,
        dayPeriodColor: Color(0xFFF5F5F5),
        dayPeriodTextColor: Colors.black87,
        dialBackgroundColor: Color(0xFFF5F5F5),
        dialHandColor: Color(0xFF4CAF82),
        dialTextColor: Colors.black87,
        entryModeIconColor: Colors.black54,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  Widget _datePickerBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: _pickerTheme(context),
      child: Localizations.override(
        context: context,
        locale: const Locale('ar', 'EG'),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    );
  }

  Widget _timePickerBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: _pickerTheme(context),
      child: Localizations.override(
        context: context,
        locale: const Locale('ar', 'EG'),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    );
  }

  Future<void> _onDateToggled(bool value) async {
    setState(() => _dateEnabled = value);
    if (!value) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
      builder: _datePickerBuilder,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _openDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('ar', 'EG'),
      builder: _datePickerBuilder,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _onTimeToggled(bool value) async {
    setState(() => _timeEnabled = value);
    if (!value) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'اختيار الوقت',
      hourLabelText: 'ساعة',
      minuteLabelText: 'دقيقة',
      builder: _timePickerBuilder,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _openTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'اختيار الوقت',
      hourLabelText: 'ساعة',
      minuteLabelText: 'دقيقة',
      builder: _timePickerBuilder,
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
            onSubtitleTap:
                _dateEnabled && _selectedDate != null ? _openDatePicker : null,
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F3)),
          ToggleRowWidget(
            icon: Icons.access_time_rounded,
            label: 'الوقت',
            value: _timeEnabled,
            onChanged: _onTimeToggled,
            subtitle: _timeEnabled && _selectedTime != null
                ? _formatTimeOfDay(_selectedTime!)
                : null,
            onSubtitleTap:
                _timeEnabled && _selectedTime != null ? _openTimePicker : null,
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
