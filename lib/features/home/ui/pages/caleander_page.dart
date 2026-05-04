import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  MethodChannel? _channel;
  late final Map<String, dynamic> _creationParams;

  @override
  void initState() {
    super.initState();
    _creationParams = {
      'initialSelectedDate': DateTime.now().toUtc().toIso8601String(),
    };
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('ios-calendar-view/methods_$id');
  }

  Future<void> setNativeSelectedDate(DateTime date) async {
    final ch = _channel;
    if (ch == null) return;
    await ch.invokeMethod<void>('setSelectedDate', <String, dynamic>{
      'date': date.toUtc().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'calendar-view',
        layoutDirection: TextDirection.rtl,
        creationParams: _creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Text('التقويم'),
        ),
      ),
    );
  }
}
