import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tawakad_app/features/home/services/device_calendar_service.dart';

/// Calendar UI for Android (and other platforms without the native iOS view).
/// Mirrors the week strip + date header + hourly timeline from iOS `CalendarView`.
class FlutterDeviceCalendarView extends StatefulWidget {
  const FlutterDeviceCalendarView({super.key});

  @override
  State<FlutterDeviceCalendarView> createState() =>
      _FlutterDeviceCalendarViewState();
}

class _FlutterDeviceCalendarViewState extends State<FlutterDeviceCalendarView> {
  final DeviceCalendarService _calendarService = DeviceCalendarService();

  DateTime _selectedDate = DateTime.now();
  List<Event> _events = [];
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    final granted = await _calendarService.ensurePermission();
    if (!mounted) return;

    if (!granted) {
      setState(() {
        _permissionDenied = true;
        _events = [];
        _isLoading = false;
      });
      return;
    }

    final events = await _calendarService.fetchEventsForDay(_selectedDate);
    if (!mounted) return;

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  void _selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_sameDay(normalized, _selectedDate)) return;
    setState(() => _selectedDate = normalized);
    _load();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> get _weekDates {
    // Week starting Saturday (common in Arabic locales).
    final daysFromSaturday = (_selectedDate.weekday + 1) % 7;
    final start = _selectedDate.subtract(Duration(days: daysFromSaturday));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  List<Event> _eventsForHour(int hour) {
    final startOfDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final slotStart = startOfDay.add(Duration(hours: hour));
    final slotEnd = slotStart.add(const Duration(hours: 1));

    return _events.where((event) {
      if (event.allDay == true) return false;
      final start = event.start?.toLocal();
      final end = event.end?.toLocal();
      if (start == null || end == null) return false;
      return start.isBefore(slotEnd) && end.isAfter(slotStart);
    }).toList()
      ..sort((a, b) {
        final aStart = a.start?.toLocal() ?? DateTime(0);
        final bStart = b.start?.toLocal() ?? DateTime(0);
        return aStart.compareTo(bStart);
      });
  }

  String _arabicDigits(int value) {
    final formatter = NumberFormat.decimalPattern('ar');
    formatter.maximumFractionDigits = 0;
    return formatter.format(value);
  }

  String _shortWeekday(DateTime date) {
    return DateFormat('EEE', 'ar').format(date);
  }

  String _gregorianHeader() {
    return DateFormat('EEEE d MMMM yyyy', 'ar').format(_selectedDate);
  }

  String _hijriHeader() {
    final h = HijriCalendar.fromDate(_selectedDate);
    return '${_arabicDigits(h.hDay)} ${h.getLongMonthName()} ${_arabicDigits(h.hYear)}';
  }

  String _hourLabel(int hour) {
    final time = DateTime(2000, 1, 1, hour);
    return DateFormat('HH:mm', 'ar').format(time);
  }

  String _eventTimeRange(Event event) {
    final start = event.start?.toLocal();
    final end = event.end?.toLocal();
    if (start == null || end == null) return '';
    final fmt = DateFormat('HH:mm', 'ar');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = Colors.red;
    final chipBg =
        isDark ? const Color(0xFF2A2F38) : const Color(0xFFF0F2F5);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            _WeekStrip(
              weekDates: _weekDates,
              selectedDate: _selectedDate,
              selectedColor: selectedColor,
              arabicDigits: _arabicDigits,
              shortWeekday: _shortWeekday,
              hijriDay: (d) => HijriCalendar.fromDate(d).hDay,
              onSelect: _selectDate,
            ),
            Divider(color: theme.dividerColor, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Text(
                    _gregorianHeader(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_hijriHeader()} هـ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                children: [
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'جاري تحميل الأحداث...',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ),
                  if (_permissionDenied)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'يرجى السماح بالوصول للتقويم من إعدادات الجهاز',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!_isLoading &&
                      !_permissionDenied &&
                      _events.where((e) => e.allDay != true).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'لا توجد أحداث في هذا اليوم',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (var hour = 0; hour <= 23; hour++) ...[
                    SizedBox(
                      height: 90,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 76,
                                child: Text(
                                  _hourLabel(hour),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    top: 44,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 90,
                            right: 0,
                            top: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final event in _eventsForHour(hour))
                                  _EventChip(
                                    title: (event.title ?? '').isEmpty
                                        ? 'بدون عنوان'
                                        : event.title!,
                                    timeRange: _eventTimeRange(event),
                                    backgroundColor: chipBg,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekDates,
    required this.selectedDate,
    required this.selectedColor,
    required this.arabicDigits,
    required this.shortWeekday,
    required this.hijriDay,
    required this.onSelect,
  });

  final List<DateTime> weekDates;
  final DateTime selectedDate;
  final Color selectedColor;
  final String Function(int) arabicDigits;
  final String Function(DateTime) shortWeekday;
  final int Function(DateTime) hijriDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          for (final date in weekDates)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(date),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Text(
                      shortWeekday(date),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: date.year == selectedDate.year &&
                                date.month == selectedDate.month &&
                                date.day == selectedDate.day
                            ? selectedColor
                            : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        arabicDigits(date.day),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: date.year == selectedDate.year &&
                                  date.month == selectedDate.month &&
                                  date.day == selectedDate.day
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      arabicDigits(hijriDay(date)),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.title,
    required this.timeRange,
    required this.backgroundColor,
  });

  final String title;
  final String timeRange;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
