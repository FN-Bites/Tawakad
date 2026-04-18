import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/cards/app_icon_badge.dart';
import 'package:tawakad_app/core/widgets/filter_bar.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_provider.dart';
import '../widgets/ble_item/ble_item_card.dart';
import '../widgets/ble_empty_state.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/create_ble_item.dart';

enum BleFilterOption { all, today, favorites }

class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  BleFilterOption _activeFilter = BleFilterOption.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ble = context.watch<BleProvider>();
    final now = DateTime.now();

    final allItems = ble.savedItems;
    final filtered = allItems.where((d) {
      switch (_activeFilter) {
        case BleFilterOption.all:
          return true;
        case BleFilterOption.today:
          return d.lastSeen.year == now.year &&
              d.lastSeen.month == now.month &&
              d.lastSeen.day == now.day;
        case BleFilterOption.favorites:
          return d.isFavorite;
      }
    }).toList();

    Widget mainContent = const Padding(
      padding: EdgeInsets.only(bottom: 200),
      child: Center(child: BleEmptyState()),
    );

    if (filtered.isNotEmpty) {
      mainContent = ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (ctx, index) => BleItemCard(item: filtered[index]),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 40,
        actions: [
          const SizedBox(width: 24),
          AppIconBadge(
            icon: Icons.person,
            iconColor: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          Text(
            'المسح',
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          AppLiquidButtons.iconWithLabel(
            icon: Icons.add,
            label: 'إضافة غرض',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useSafeArea: true,
                builder: (_) => const SizedBox(
                  height: double.infinity,
                  child: CreateBleItemPage(),
                ),
              );
            },
            fillColor: AppColors.primary,
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AppFilterBar(
                labels: const [
                  'جميع الأغراض',
                  'أغراض اليوم',
                  'الأغراض المفضلة'
                ],
                chipWidth: 110.0,
                initialIndex: 0,
                onFilterChanged: (index) {
                  setState(() => _activeFilter = BleFilterOption.values[index]);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: mainContent,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
