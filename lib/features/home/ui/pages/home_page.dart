import 'package:flutter/material.dart';
import 'pack_list.dart';
import '../widgets/pack_list/pack_list_card.dart';
import '../widgets/buttons/pack_list_icon_badge.dart';
import '../widgets/pack_list_card_theme.dart';
import '../widgets/buttons/filter_bar.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/search_empty_state.dart';

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
  final List<PackList> _registeredList = [
    PackList(
      title: 'الجيم',
      itemCount: 9,
      date: DateTime.now(),
      cardTheme: PackListCardTheme.pink,
    ),
    PackList(
      title: 'جامعة',
      itemCount: 5,
      date: DateTime.now(),
      cardTheme: PackListCardTheme.blue,
    ),
  ];

  List<PackList> get _filteredList {
    if (widget.searchQuery.isEmpty) return _registeredList;
    final q = widget.searchQuery.toLowerCase();
    return _registeredList
        .where((p) => p.title.toLowerCase().contains(q))
        .toList();
  }

  void _openAddPackList() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const Text("Modal bottom sheet"),
    );
  }

  void _removePackList(PackList packlist) {
    setState(() => _registeredList.remove(packlist));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredList;

    Widget mainContent = const Padding(
      padding: EdgeInsets.only(bottom: 200),
      child: Center(
        child: HomeEmptyState(),
      ),
    );

    if (filtered.isNotEmpty) {
      mainContent = PackListCard(
        packList: filtered,
        onRemoveList: _removePackList,
      );
    } else if (widget.searchQuery.isNotEmpty && filtered.isEmpty) {
      mainContent = const Padding(
        padding: EdgeInsets.only(bottom: 200),
        child: Center(
          child: SearchEmptyState(),
        ),
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
          PackListIconBadge(
            icon: Icons.person,
            iconColor: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          Text(
            'الرئيسية',
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          PackListIconBadge(
            onPressed: _openAddPackList,
            icon: Icons.add,
            bold: true,
            iconColor: theme.iconTheme.color ?? theme.colorScheme.onSurface,
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
              child: GlassFilterBar(
                initialFilter: FilterOption.today,
                onFilterChanged: (filter) {},
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
