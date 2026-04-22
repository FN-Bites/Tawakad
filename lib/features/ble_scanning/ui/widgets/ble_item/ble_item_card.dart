import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/cards/app_list_card.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';

class BleItemCard extends StatelessWidget {
  final BleItem item;

  const BleItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      color: item.color,
      iconPath: item.iconPath,
      title: item.name,
      subtitle: const Text(
        '',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
