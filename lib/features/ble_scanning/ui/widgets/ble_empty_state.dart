import 'package:flutter/material.dart';

class BleEmptyState extends StatelessWidget {
  const BleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.category_rounded, size: 80, color: Colors.blue),
        SizedBox(height: 16),
        Text(
          'لا توجد أغراض حالياً',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        Text(
          'اضغط على إضافة غرض لإنشاء غرض جديد',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
