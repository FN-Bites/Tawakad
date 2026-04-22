import 'package:flutter/material.dart';
import '../../ui/animation/scan_rive.dart';

class MapBleEmptyState extends StatelessWidget {
  final bool scanning;

  const MapBleEmptyState({super.key, required this.scanning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 200,
            height: 200,
            child: BluetoothScanRive(),
          ),
          Text(
            scanning ? 'يتم البحث…' : 'لا توجد أجهزة بعد',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            scanning
                ? 'جارٍ البحث عن الأجهزة القريبة'
                : 'اضغط على المسح لرؤية الأجهزة القريبة',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
