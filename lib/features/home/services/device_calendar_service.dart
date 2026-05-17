import 'package:device_calendar/device_calendar.dart';

/// Reads calendar events from the device calendar (Android / other non-iOS targets).
class DeviceCalendarService {
  DeviceCalendarService({DeviceCalendarPlugin? plugin})
      : _plugin = plugin ?? DeviceCalendarPlugin();

  final DeviceCalendarPlugin _plugin;

  Future<bool> ensurePermission() async {
    final has = await _plugin.hasPermissions();
    if (has.isSuccess && has.data == true) return true;
    final requested = await _plugin.requestPermissions();
    return requested.isSuccess && requested.data == true;
  }

  Future<List<Event>> fetchEventsForDay(DateTime day) async {
    final calendarsResult = await _plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final params = RetrieveEventsParams(startDate: start, endDate: end);

    final events = <Event>[];
    for (final calendar in calendarsResult.data!) {
      final id = calendar.id;
      if (id == null) continue;
      final result = await _plugin.retrieveEvents(id, params);
      if (result.isSuccess && result.data != null) {
        events.addAll(result.data!);
      }
    }

    events.sort((a, b) {
      final aStart = a.start?.toLocal() ?? DateTime(0);
      final bStart = b.start?.toLocal() ?? DateTime(0);
      return aStart.compareTo(bStart);
    });
    return events;
  }
}
