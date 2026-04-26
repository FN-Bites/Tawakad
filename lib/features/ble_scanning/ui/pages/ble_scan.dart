import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/cards/app_icon_badge.dart';
import 'package:tawakad_app/core/widgets/filter_bar.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';
import '../widgets/ble_item/ble_item_card.dart';
import '../widgets/ble_empty_state.dart';
import 'package:tawakad_app/core/widgets/search_empty_state.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/create_ble_item.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/how_to_use_sheet.dart';
import 'package:tawakad_app/core/widgets/cards/app_swipe_to_delete.dart';

enum BleFilterOption { all, today, favorites }

class BleScanPage extends StatefulWidget {
  final VoidCallback? onGoToScan;
  final String searchQuery;

  const BleScanPage({
    super.key,
    this.onGoToScan,
    this.searchQuery = '',
  });

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  BleFilterOption _activeFilter = BleFilterOption.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bleItems = context.watch<BleItemProvider>();
    final now = DateTime.now();

    final allItems = bleItems.savedItems;

    final afterFilter = allItems.where((d) {
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

    final filtered = widget.searchQuery.isEmpty
        ? afterFilter
        : afterFilter
            .where((d) =>
                d.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
            .toList();

    Widget mainContent = const Padding(
      padding: EdgeInsets.only(bottom: 200),
      child: Center(child: BleEmptyState()),
    );

    if (filtered.isNotEmpty) {
      mainContent = ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (ctx, index) {
          final item = filtered[index];
          return AppSwipeToDelete(
            onDelete: () {
              context.read<BleItemProvider>().removeSavedItem(item.deviceId);
            },
            dialogTitle: 'حذف الغرض',
            dialogMessage: 'هل أنت متأكد أنك تريد حذف "${item.name}"؟',
            confirmLabel: 'حذف',
            cancelLabel: 'إلغاء',
            child: BleItemCard(
              item: item,
              allLists: context.read<PackListProvider>().lists,
            ),
          );
        },
      );
    } else if (widget.searchQuery.isNotEmpty && filtered.isEmpty) {
      mainContent = const Padding(
        padding: EdgeInsets.only(bottom: 200),
        child: Center(child: SearchEmptyState()),
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
          Text('المسح', style: theme.textTheme.bodyLarge),
          const Spacer(),
          AppLiquidButtons.icon(
            icon: Icons.info_outline,
            onPressed: () => HowToUseSheet.show(context),
          ),
          const SizedBox(width: 10),
          AppLiquidButtons.iconWithLabel(
            icon: Icons.add,
            label: 'إضافة غرض',
            onPressed: () {
              final shellNavigator = Navigator.of(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useSafeArea: true,
                builder: (_) => SizedBox(
                  height: double.infinity,
                  child: CreateBleItemPage(
                    onItemSaved: () {
                      shellNavigator.pop();
                      widget.onGoToScan?.call();
                    },
                  ),
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
