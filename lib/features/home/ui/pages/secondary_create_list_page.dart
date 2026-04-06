import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';
import '../widgets/item_card.dart';
import '../widgets/date_time_card.dart';
import '../widgets/sharing_card.dart';

class SecondaryCreateListPage extends StatefulWidget {
  final String title;
  final String iconPath;
  final Color color;
  final bool isFavorite;
  final String? event;
  final PackList? existing;

  const SecondaryCreateListPage({
    super.key,
    required this.title,
    required this.iconPath,
    required this.color,
    required this.isFavorite,
    this.event,
    this.existing,
  });

  @override
  State<SecondaryCreateListPage> createState() =>
      _SecondaryCreateListPageState();
}

class _SecondaryCreateListPageState extends State<SecondaryCreateListPage> {
  final _itemsKey = GlobalKey<ItemsCardState>();
  final _dateTimeKey = GlobalKey<DateTimeCardState>();
  final _sharingKey = GlobalKey<SharingCardState>();

  String? _formatTime(TimeOfDay? t) {
    if (t == null) return null;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _saveList() {
    FocusScope.of(context).unfocus();

    final dateTimeState = _dateTimeKey.currentState!;
    final sharingState = _sharingKey.currentState!;
    final provider = context.read<PackListProvider>();

    if (widget.existing != null) {
      provider.editList(
        id: widget.existing!.id,
        title: widget.title,
        iconPath: widget.iconPath,
        color: widget.color,
        isFavorite: widget.isFavorite,
        date: dateTimeState.selectedDate,
        time: _formatTime(dateTimeState.selectedTime),
        event: widget.event,
        repeat: dateTimeState.repeatEnabled,
        repeatDays: dateTimeState.selectedDays,
        isShared: sharingState.sharingEnabled,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      provider.createList(
        title: widget.title,
        iconPath: widget.iconPath,
        color: widget.color,
        isFavorite: widget.isFavorite,
        items: _itemsKey.currentState!.items.toList(),
        date: dateTimeState.selectedDate,
        time: _formatTime(dateTimeState.selectedTime),
        event: widget.event,
        repeat: dateTimeState.repeatEnabled,
        repeatDays: dateTimeState.selectedDays,
        isShared: sharingState.sharingEnabled,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.existing;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 22),
                _buildListPreviewHeader(),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الأغراض',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8A8A8E),
                          ),
                    ),
                  ),
                ),
                e != null
                    ? ItemsCard(
                        key: _itemsKey,
                        accentColor: widget.color,
                        listId: e.id,
                      )
                    : ItemsCard(
                        key: _itemsKey,
                        accentColor: widget.color,
                      ),
                const SizedBox(height: 22),
                DateTimeCard(
                  key: _dateTimeKey,
                  initialDate: e?.date,
                  initialTime: e?.time,
                  initialRepeat: e?.repeat ?? false,
                  initialRepeatDays: e?.repeatDays ?? [],
                ),
                const SizedBox(height: 22),
                SharingCard(
                  key: _sharingKey,
                  initialSharing: e?.isShared ?? false,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassBackButton(),
          _circleButton(
            child: const CustomPaint(
              size: Size(22, 22),
              painter: BoldIconPainter(
                icon: Icons.check,
                color: Colors.white,
                size: 22,
                strokeExtra: 1.2,
              ),
            ),
            onTap: _saveList,
            backgroundColor: const Color(0xFF1F8EFA),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required Widget child,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildListPreviewHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: widget.color,
          child: Image.asset(
            widget.iconPath,
            width: 24,
            height: 24,
            color: Colors.white,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.list_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
