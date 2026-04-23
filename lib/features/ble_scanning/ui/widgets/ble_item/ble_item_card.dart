import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/cards/app_list_card.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';

class BleItemCard extends StatelessWidget {
  final BleItem item;
  final List<PackList> allLists;

  const BleItemCard({
    super.key,
    required this.item,
    required this.allLists,
  });

  @override
  Widget build(BuildContext context) {
    final affiliated =
        allLists.where((l) => item.listIds.contains(l.id)).toList();

    return AppListCard(
      color: item.color,
      iconPath: item.iconPath,
      title: item.name,
      subtitle: affiliated.isEmpty
          ? const SizedBox.shrink()
          : _AffiliatedListsWidget(lists: affiliated),
    );
  }
}

class _AffiliatedListsWidget extends StatelessWidget {
  final List<PackList> lists;

  const _AffiliatedListsWidget({required this.lists});

  @override
  Widget build(BuildContext context) {
    final rows = <List<PackList>>[];
    for (var i = 0; i < lists.length; i += 3) {
      rows.add(lists.sublist(i, i + 3 > lists.length ? lists.length : i + 3));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((list) => _ListChip(list: list)).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _ListChip extends StatelessWidget {
  final PackList list;

  const _ListChip({required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.list_alt_rounded,
            size: 12,
            color: Colors.white.withOpacity(0.85),
          ),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 72),
            child: Text(
              list.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
