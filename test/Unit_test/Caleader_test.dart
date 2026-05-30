import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawakad_app/features/calender/services/device_calendar_service.dart';
import 'package:timezone/data/latest.dart' as timezone;

void main() {
  late FakeDeviceCalendarPlugin plugin;
  late DeviceCalendarService service;

  setUpAll(() {
    timezone.initializeTimeZones();
  });

  setUp(() {
    plugin = FakeDeviceCalendarPlugin();
    service = DeviceCalendarService(plugin: plugin);
  });

  group('DeviceCalendarService', () {
    test(
      'ensurePermission returns true when permission already granted',
      () async {
        plugin.hasPermissionsResult = successResult(true);

        final result = await service.ensurePermission();

        expect(result, true);
        expect(plugin.hasPermissionsCallCount, 1);
        expect(plugin.requestPermissionsCallCount, 0);
      },
    );

    test(
      'ensurePermission requests permission when not granted',
      () async {
        plugin.hasPermissionsResult = successResult(false);
        plugin.requestPermissionsResult = successResult(true);

        final result = await service.ensurePermission();

        expect(result, true);
        expect(plugin.hasPermissionsCallCount, 1);
        expect(plugin.requestPermissionsCallCount, 1);
      },
    );

    test(
      'ensurePermission returns false when permission request is denied',
      () async {
        plugin.hasPermissionsResult = successResult(false);
        plugin.requestPermissionsResult = successResult(false);

        final result = await service.ensurePermission();

        expect(result, false);
      },
    );

    test(
      'fetchEventsForDay returns empty list when calendars retrieval fails',
      () async {
        plugin.calendarsResult = failureResult();

        final result = await service.fetchEventsForDay(DateTime(2026, 5, 30));

        expect(result, isEmpty);
      },
    );

    test('fetchEventsForDay ignores calendars with null id', () async {
      plugin.calendarsResult = successResult(
        UnmodifiableListView([Calendar(name: 'No ID')]),
      );

      final result = await service.fetchEventsForDay(DateTime(2026, 5, 30));

      expect(result, isEmpty);
      expect(plugin.retrievedCalendarIds, isEmpty);
    });

    test('fetchEventsForDay returns events sorted by start time', () async {
      final earlyEvent = Event(
        'calendar-1',
        title: 'Early event',
        start: TZDateTime.local(2026, 5, 30, 8),
      );
      final lateEvent = Event(
        'calendar-1',
        title: 'Late event',
        start: TZDateTime.local(2026, 5, 30, 10),
      );

      plugin.calendarsResult = successResult(
        UnmodifiableListView([Calendar(id: 'calendar-1')]),
      );
      plugin.eventsByCalendarId['calendar-1'] = successResult(
        UnmodifiableListView([lateEvent, earlyEvent]),
      );

      final result = await service.fetchEventsForDay(DateTime(2026, 5, 30));

      expect(result, [earlyEvent, lateEvent]);
      expect(plugin.retrievedCalendarIds, ['calendar-1']);
    });
  });
}

class FakeDeviceCalendarPlugin extends DeviceCalendarPlugin {
  FakeDeviceCalendarPlugin() : super.private();

  Result<bool> hasPermissionsResult = successResult(true);
  Result<bool> requestPermissionsResult = successResult(true);
  Result<UnmodifiableListView<Calendar>> calendarsResult =
      successResult(UnmodifiableListView([]));
  final eventsByCalendarId =
      <String, Result<UnmodifiableListView<Event>>>{};

  int hasPermissionsCallCount = 0;
  int requestPermissionsCallCount = 0;
  final retrievedCalendarIds = <String?>[];

  @override
  Future<Result<bool>> hasPermissions() async {
    hasPermissionsCallCount++;
    return hasPermissionsResult;
  }

  @override
  Future<Result<bool>> requestPermissions() async {
    requestPermissionsCallCount++;
    return requestPermissionsResult;
  }

  @override
  Future<Result<UnmodifiableListView<Calendar>>> retrieveCalendars() async {
    return calendarsResult;
  }

  @override
  Future<Result<UnmodifiableListView<Event>>> retrieveEvents(
    String? calendarId,
    RetrieveEventsParams? retrieveEventsParams,
  ) async {
    retrievedCalendarIds.add(calendarId);
    return eventsByCalendarId[calendarId] ??
        successResult(UnmodifiableListView([]));
  }
}

Result<T> successResult<T>(T data) {
  return Result<T>()..data = data;
}

Result<T> failureResult<T>() {
  return Result<T>()
    ..errors = [
      const ResultError(1, 'Failed'),
    ];
}
