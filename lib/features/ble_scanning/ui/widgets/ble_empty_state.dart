import 'package:flutter/material.dart';
import '../../ui/animation/devices_rive.dart';

class BleEmptyState extends StatelessWidget {
  const BleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: DevicesRive(isDark: isDark),
          ),
          Text(
            'لا توجد أغراض حالياً',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'قم بإضافة أغراضك لتفعيل المسح التلقائي',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
