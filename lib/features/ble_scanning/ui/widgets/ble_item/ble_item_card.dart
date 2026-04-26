import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/cards/app_list_card.dart';
import 'package:tawakad_app/core/widgets/cards/app_count_badge.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/ble_item_detail_page.dart';
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

    const badgeLabel = 'تفاصيل الغرض';

    return AppListCard(
      color: item.color,
      iconPath: item.iconPath,
      title: item.name,
      subtitle:
          affiliated.isEmpty ? null : _AffiliatedListsWidget(lists: affiliated),
      trailing: AppCountBadge(
        label: badgeLabel,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BleItemDetailPage(item: item),
          ),
        ),
      ),
    );
  }
}

class _AffiliatedListsWidget extends StatelessWidget {
  final List<PackList> lists;

  const _AffiliatedListsWidget({required this.lists});

  @override
  Widget build(BuildContext context) {
    final display = lists.take(2).toList();
    final extra = lists.length - display.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...display.map((list) => _ListChip(list: list)),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '+$extra',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),
      ],
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
            constraints: const BoxConstraints(maxWidth: 68),
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
