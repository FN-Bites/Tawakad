import 'package:flutter/material.dart';
import 'package:tawakad_app/features/home/ui/pages/pack_list.dart';
import '../buttons/pack_list_icon_badge.dart';
import '../buttons/pack_list_item_count_button.dart';

class PackListItem extends StatelessWidget {
  const PackListItem(this.packlist, {super.key});

  final PackList packlist;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Text(packlist.title),
            const SizedBox(height: 4),
            Row(
              children: [
                const PackListIconBadge(
                  icon: Icons.fitness_center_rounded,
                ),
                Text(packlist.formattedDate),
                const Spacer(),
                PackListItemCountButton(itemCount: packlist.itemCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
