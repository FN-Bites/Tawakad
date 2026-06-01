import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../../home/provider/pack_list_provider.dart';
import '../../../home/model/pack_list.dart';

class FlutterDeviceCalendarView extends StatefulWidget {
  const FlutterDeviceCalendarView({super.key});

  @override
  State<FlutterDeviceCalendarView> createState() =>
      _FlutterDeviceCalendarViewState();
}

class _FlutterDeviceCalendarViewState extends State<FlutterDeviceCalendarView> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  List<DateTime> get _weekDates {
    final daysFromSaturday = (_selectedDate.weekday + 1) % 7;
    final start = _selectedDate.subtract(Duration(days: daysFromSaturday));
    return List.generate(7, (i) => start.add(Duration(days: i)));
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

  /// Hour label with Arabic-Indic digits e.g. ٠٣:٠٠
  String _hourLabel(int hour) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final formatted = DateFormat('HH:mm').format(DateTime(2000, 1, 1, hour));
    return formatted.splitMapJoin('', onNonMatch: (s) {
      final i = en.indexOf(s);
      return i >= 0 ? ar[i] : s;
    });
  }

  /// Minutes component from "HH:mm" string for vertical positioning
  int _minutesFromTimeString(String? time) {
    if (time == null) return 0;
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  List<PackList> _listsForDay(List<PackList> lists, DateTime day) {
    return lists.where((list) {
      if (list.date == null) return false;
      return _sameDay(list.date!, day);
    }).toList();
  }

  /// Parse hour from the "HH:mm" time string, NOT from date.hour
  /// because date is stored as midnight and time is a separate field.
  int _hourFromTimeString(String? time) {
    if (time == null) return 0;
    final parts = time.split(':');
    if (parts.isEmpty) return 0;
    return int.tryParse(parts[0]) ?? 0;
  }

  List<PackList> _listsForHour(List<PackList> lists, int hour) {
    return lists.where((list) {
      if (list.date == null) return false;
      return _hourFromTimeString(list.time) == hour;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PackListProvider>(context);
    final allLists = provider.lists;
    final selectedDayLists = _listsForDay(allLists, _selectedDate);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // ── Week strip ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                for (final date in _weekDates)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(date),
                      child: Column(
                        children: [
                          Text(
                            _shortWeekday(date),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _sameDay(date, _selectedDate)
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                            child: Text(
                              _arabicDigits(date.day),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _sameDay(date, _selectedDate)
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _listsForDay(allLists, date).isNotEmpty
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _arabicDigits(HijriCalendar.fromDate(date).hDay),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),
          // ── Selected day header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(
                  _gregorianHeader(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_hijriHeader()} هـ',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),
          // ── Hourly timeline ─────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              children: [
                if (selectedDayLists.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'لا توجد قوائم في هذا اليوم',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (var hour = 0; hour <= 23; hour++)
                  SizedBox(
                    height: 90,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Hour label + divider ───────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 76,
                              child: Text(
                                _hourLabel(hour),
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
                        // ── Events positioned by minute offset ─────
                        Positioned(
                          left: 90,
                          right: 0,
                          top: 0,
                          height: 90,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              for (final list in _listsForHour(
                                selectedDayLists,
                                hour,
                              ))
                                Positioned(
                                  top: (_minutesFromTimeString(list.time) /
                                          60.0) *
                                      90.0,
                                  left: 0,
                                  right: 0,
                                  child: _EventCard(list: list),
                                ),
                            ],
                          ),
                        ),
                      ],
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

/// Event card with full list.color background tint, no English time.
class _EventCard extends StatelessWidget {
  const _EventCard({required this.list});

  final PackList list;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Full card background = list color at 25% opacity
    final cardColor = list.color.withValues(alpha: 0.25);
    // Left accent bar = list color at full opacity
    final barColor = list.color;
    // Text color: use the list color darkened for legibility
    final textColor = list.color.withValues(alpha: 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Solid colour bar on the right (RTL layout) ──────────
            Container(
              width: 5,
              color: barColor,
            ),
            // ── Title only — no time text ────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  list.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
