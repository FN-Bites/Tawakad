import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/cards/app_swipe_to_delete.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'package:tawakad_app/features/home/ui/widgets/pack_list/pack_list_item.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';

class PackListCard extends StatelessWidget {
  final List<PackList> lists;

  const PackListCard({super.key, required this.lists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (ctx, index) => AppSwipeToDelete(
        key: ValueKey(lists[index].id),
        dialogTitle: 'حذف القائمة',
        dialogMessage: 'هل أنت متأكد أنك تريد حذف هذه القائمة؟',
        onDelete: () =>
            context.read<PackListProvider>().removeList(lists[index].id),
        child: PackListItem(lists[index]),
      ),
    );
  }
}
