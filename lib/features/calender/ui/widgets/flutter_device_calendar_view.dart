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

class _FlutterDeviceCalendarViewState
    extends State<FlutterDeviceCalendarView> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
    });
  }

  List<DateTime> get _weekDates {
    final daysFromSaturday =
        (_selectedDate.weekday + 1) % 7;

    final start = _selectedDate.subtract(
      Duration(days: daysFromSaturday),
    );

    return List.generate(
      7,
      (i) => start.add(Duration(days: i)),
    );
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
    return DateFormat(
      'EEEE d MMMM yyyy',
      'ar',
    ).format(_selectedDate);
  }

  String _hijriHeader() {
    final h = HijriCalendar.fromDate(_selectedDate);

    return '${_arabicDigits(h.hDay)} '
        '${h.getLongMonthName()} '
        '${_arabicDigits(h.hYear)}';
  }

  String _hourLabel(int hour) {
    final time = DateTime(2000, 1, 1, hour);

    return DateFormat(
      'HH:mm',
      'ar',
    ).format(time);
  }

  List<PackList> _listsForDay(
    List<PackList> lists,
    DateTime day,
  ) {
    return lists.where((list) {
      if (list.date == null) return false;

      return _sameDay(
        list.date!,
        day,
      );
    }).toList();
  }

  List<PackList> _listsForHour(
    List<PackList> lists,
    int hour,
  ) {
    return lists.where((list) {
      if (list.date == null) return false;

      return list.date!.hour == hour;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<PackListProvider>(context);

    final allLists = provider.lists;

    final selectedDayLists =
        _listsForDay(allLists, _selectedDate);

    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    final chipBg = isDark
        ? const Color(0xFF2A2F38)
        : const Color(0xFFF0F2F5);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
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
                            style: theme
                                .textTheme.titleSmall
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _sameDay(
                                date,
                                _selectedDate,
                              )
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                            child: Text(
                              _arabicDigits(
                                date.day,
                              ),
                              style: theme
                                  .textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                                color: _sameDay(
                                  date,
                                  _selectedDate,
                                )
                                    ? Colors.white
                                    : theme.colorScheme
                                        .onSurface,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _listsForDay(
                                allLists,
                                date,
                              ).isNotEmpty
                                  ? Colors.red
                                  : Colors.transparent,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _arabicDigits(
                              HijriCalendar
                                  .fromDate(date)
                                  .hDay,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(
            color: theme.dividerColor,
            height: 1,
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Column(
              children: [
                Text(
                  _gregorianHeader(),
                  style: theme
                      .textTheme.headlineMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_hijriHeader()} هـ',
                  style: theme
                      .textTheme.titleLarge
                      ?.copyWith(
                    color: theme
                        .colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: theme.dividerColor,
            height: 1,
          ),

          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                0,
                10,
                20,
              ),
              children: [
                if (selectedDayLists.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Text(
                      'لا توجد قوائم في هذا اليوم',
                      textAlign: TextAlign.center,
                    ),
                  ),

                for (var hour = 0;
                    hour <= 23;
                    hour++) ...[
                  SizedBox(
                    height: 90,
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 76,
                              child: Text(
                                _hourLabel(hour),
                                textAlign:
                                    TextAlign.end,
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  left: 12,
                                  top: 44,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: theme
                                      .dividerColor,
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
                            children: [
                              for (final list
                                  in _listsForHour(
                                selectedDayLists,
                                hour,
                              ))
                                Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 6,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: chipBg,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 4,
                                        backgroundColor:
                                            list.color,
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              list.title,
                                              style: theme
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),

                                            if (list.time !=
                                                null)
                                              Text(
                                                list.time!,
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
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}