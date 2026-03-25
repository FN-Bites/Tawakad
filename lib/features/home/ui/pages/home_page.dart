import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'pack_list.dart';
import '../widgets/pack_list/pack_list_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  //Dummy data
  final List<PackList> _registeredList = [
    PackList(title: 'Gym', itemCount: 23, date: DateTime.now()),
    PackList(title: 'Uni', itemCount: 19, date: DateTime.now()),
  ];

  void _openAddPackList() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => const Text("Modal bottom sheet"));
  }

  void _removePackList(PackList packlist) {
    setState(() {
      _registeredList.remove(packlist);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
          const Spacer(),
          IconButton(onPressed: _openAddPackList, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text("The filters"),
          Expanded(
            child: PackListCard(
              packList: _registeredList,
              onRemoveList: _removePackList,
            ),
          ),
        ],
      ),
    );
  }
}
