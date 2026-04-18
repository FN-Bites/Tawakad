import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/cards/app_list_card.dart';
import 'package:tawakad_app/core/widgets/cards/app_count_badge.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/ui/pages/pack_list_items_page.dart';

class PackListItem extends StatelessWidget {
  const PackListItem(this.packlist, {super.key});

  final PackList packlist;

  String _toArabicNumerals(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < western.length; i++) {
      input = input.replaceAll(western[i], arabic[i]);
    }
    return input;
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return _toArabicNumerals(time);
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return _toArabicNumerals(time);
    final period = hour < 12 ? 'ص' : 'م';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '${_toArabicNumerals(hour12.toString())}:${_toArabicNumerals(minuteStr)} $period';
  }

  String _itemLabel() {
    final count = packlist.itemCount;
    if (count == 1) return '${_toArabicNumerals('1')} غرض واحد';
    if (count == 2) return '${_toArabicNumerals('2')} غرضان';
    if (count <= 10) return '${_toArabicNumerals(count.toString())} أغراض';
    return '${_toArabicNumerals(count.toString())} غرض';
  }

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      color: packlist.color,
      iconPath: packlist.iconPath,
      title: packlist.title,
      subtitle: packlist.date == null && packlist.time == null
          ? null
          : Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  packlist.time != null ? _formatTime(packlist.time!) : '',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      trailing: AppCountBadge(
        label: _itemLabel(),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PackListItemsPage(listId: packlist.id),
          ),
        ),
      ),
    );
  }
}
