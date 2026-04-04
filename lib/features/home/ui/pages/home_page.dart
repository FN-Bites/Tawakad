import 'package:flutter/material.dart';
import 'pack_list.dart';
import '../widgets/pack_list/pack_list_card.dart';
import '../widgets/buttons/pack_list_icon_badge.dart';
import '../widgets/pack_list_card_theme.dart';
import '../widgets/buttons/filter_bar.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/search_empty_state.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_search_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  String _searchQuery = '';
  List<PackList> get _filteredList {
    if (_searchQuery.isEmpty) return _registeredList;
    final q = _searchQuery.toLowerCase();
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
    final listIndex = _registeredList.indexOf(packlist);
    setState(() => _registeredList.remove(packlist));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text('تم حذف القائمة'),
        action: SnackBarAction(
          label: 'رجوع',
          onPressed: () {
            setState(() => _registeredList.insert(listIndex, packlist));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredList;

    Widget mainContent = const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 350),
        child: HomeEmptyState(),
      ),
    );

    if (filtered.isNotEmpty) {
      mainContent = PackListCard(
        packList: filtered,
        onRemoveList: _removePackList,
      );
    } else if (_searchQuery.isNotEmpty && filtered.isEmpty) {
      mainContent = const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 350),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.topRight,
              child: GlassFilterBar(
                initialFilter: FilterOption.today,
                onFilterChanged: (filter) {},
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 40,
              ),
              child: mainContent,
            ),
          ),
          SafeArea(
            top: false,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: GlassSearchButton(
                    hintText: 'ابحث عن قائمة',
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClosed: () {
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
