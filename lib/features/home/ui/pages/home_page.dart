import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'pack_list.dart';
import '../widgets/pack_list/pack_list_card.dart';
import '../widgets/buttons/pack_list_icon_badge.dart';
import '../widgets/pack_list_card_theme.dart';
import '../widgets/buttons/filter_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  //Dummy data
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
    )
  ];

  void _openAddPackList() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => const Text("Modal bottom sheet"));
  }

  void _removePackList(PackList packlist) {
    final listIndex = _registeredList.indexOf(packlist);
    setState(() {
      _registeredList.remove(packlist);
    });
    //Undo remove button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text('تم حذف القائمة'),
        action: SnackBarAction(
          label: 'رجوع',
          onPressed: () {
            setState(() {
              _registeredList.insert(listIndex, packlist);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text("لا يوجد اي قوائم لديك قم بالاضافة"),
    );

    if (_registeredList.isNotEmpty) {
      mainContent = PackListCard(
        packList: _registeredList,
        onRemoveList: _removePackList,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 40,
        actions: [
          const SizedBox(width: 24),
          const PackListIconBadge(
            icon: Icons.person,
            iconColor: Colors.black,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            'الرئيسية',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          PackListIconBadge(
            onPressed: _openAddPackList,
            icon: Icons.add,
            bold: true,
            iconColor: Colors.black,
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
        ],
      ),
    );
  }
}
