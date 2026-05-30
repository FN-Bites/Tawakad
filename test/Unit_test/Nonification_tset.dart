import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tawakad_app/core/services/notification_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationSettingsService', () {
    test(
      'isAppEnabled returns false when notifications_app_enabled is not set',
      () async {
        final service = NotificationSettingsService();

        final result = await service.isAppEnabled();

        expect(result, false);
      },
    );

    test(
      'setAppEnabled saves true value',
      () async {
        final service = NotificationSettingsService();

        await service.setAppEnabled(true);

        final result = await service.isAppEnabled();

        expect(result, true);
      },
    );
    test(
      'isMedicationEnabled returns true by default when no value is stored',
      () async {
        final service = NotificationSettingsService();

        final result = await service.isMedicationEnabled();

        expect(result, true);
      },
    );
    test(
      'setMedicationEnabled saves false value',
      () async {
        final service = NotificationSettingsService();

        await service.setMedicationEnabled(false);

        final result = await service.isMedicationEnabled();

        expect(result, false);
      },
    );
    test(
      'isListsEnabled returns true by default when no value is stored',
      () async {
        final service = NotificationSettingsService();

        final result = await service.isListsEnabled();

        expect(result, true);
      },
    );
     test(
      'setListsEnabled saves true value',
      () async {
        final service = NotificationSettingsService();

        await service.setListsEnabled(true);

        final result = await service.isListsEnabled();

        expect(result, true);
      },
    );
      test(
      'setListsEnabled saves false value',
      () async {
        final service = NotificationSettingsService();

        await service.setListsEnabled(false);

        final result = await service.isListsEnabled();

        expect(result, false);
      },
    );
     test(
      'isRemindersEnabled returns true by default when no value is stored',
      () async {
        final service = NotificationSettingsService();

        final result = await service.isRemindersEnabled();

        expect(result, true);
      },
    );
       test(
      'setRemindersEnabled saves false value',
      () async {
        final service = NotificationSettingsService();

        await service.setRemindersEnabled(false);

        final result = await service.isRemindersEnabled();

        expect(result, false);
      },
    );
  });
}
