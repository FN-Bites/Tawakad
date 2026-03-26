import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_buttons/app_liquid_buttons.dart';

class PackListItemCountButton extends StatelessWidget {
  const PackListItemCountButton({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppLiquidButtons.custom(
      height: 54,
      onPressed: () {},
      child: Row(
        children: [
          Text('$itemCount أغراض',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontSize: 14)),
          const Icon(Icons.chevron_right, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}
