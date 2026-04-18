import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalendarPage extends StatelessWidget {
  CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: UiKitView(
        viewType: 'ios-calendar-view',
        creationParamsCodec: StandardMessageCodec(),
      ),
    );
  }
}
