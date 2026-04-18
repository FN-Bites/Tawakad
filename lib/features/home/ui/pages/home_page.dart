import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/pack_list_provider.dart';
import '../widgets/pack_list/pack_list_card.dart';
import 'package:tawakad_app/core/widgets/cards/app_icon_badge.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../widgets/home_empty_state.dart';
import '../../../../core/widgets/search_empty_state.dart';
import '../pages/primary_create_list_page.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';

enum FilterOption { today, favorites, all }

class HomePage extends StatefulWidget {
  final String searchQuery;

  const HomePage({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  FilterOption _activeFilter = FilterOption.today;

  void _openAddPackList() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) => const PrimaryCreateListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLists = context.watch<PackListProvider>().lists;
    final today = DateTime.now();

    final afterFilter = allLists.where((p) {
      switch (_activeFilter) {
        case FilterOption.today:
          if (p.date == null) return false;
          return p.date!.year == today.year &&
              p.date!.month == today.month &&
              p.date!.day == today.day;
        case FilterOption.favorites:
          return p.isFavorite;
        case FilterOption.all:
          return true;
      }
    }).toList();

    final filtered = widget.searchQuery.isEmpty
        ? afterFilter
        : afterFilter
            .where((p) => p.title
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()))
            .toList();

    Widget mainContent = const Padding(
      padding: EdgeInsets.only(bottom: 200),
      child: Center(child: HomeEmptyState()),
    );

    if (filtered.isNotEmpty) {
      mainContent = PackListCard(lists: filtered);
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
          Text(
            'الرئيسية',
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          AppLiquidButtons.iconWithLabel(
            icon: Icons.add,
            label: 'إضافة قائمة',
            onPressed: _openAddPackList,
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
                  'قوائم اليوم',
                  'القوائم المفضلة',
                  'جميع القوائم',
                ],
                chipWidth: 115.0,
                initialIndex: 0,
                onFilterChanged: (index) {
                  setState(() => _activeFilter = FilterOption.values[index]);
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
