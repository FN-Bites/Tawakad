import 'package:flutter/material.dart';
import 'package:tawakad_app/features/home/ui/widgets/pack_list/pack_list_item.dart';
import '../../pages/pack_list.dart';

class PackListCard extends StatelessWidget {
  const PackListCard(
      {super.key, required this.packList, required this.onRemoveList});

  final void Function(PackList packlist) onRemoveList;
  final List<PackList> packList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: packList.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(packList[index]),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          onRemoveList(packList[index]);
        },
        child: PackListItem(packList[index]),
      ),
    );
  }
}
