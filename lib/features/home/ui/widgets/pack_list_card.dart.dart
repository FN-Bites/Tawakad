import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_overlays.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'pack_list/pack_list_item.dart';
import '../../model/pack_list.dart';

class PackListCard extends StatelessWidget {
  final List<PackList> lists;

  const PackListCard({super.key, required this.lists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (ctx, index) => _SwipeToDeleteItem(
        key: ValueKey(lists[index].id),
        onDelete: () =>
            context.read<PackListProvider>().removeList(lists[index].id),
        child: PackListItem(lists[index]),
      ),
    );
  }
}

class _SwipeToDeleteItem extends StatefulWidget {
  const _SwipeToDeleteItem({
    super.key,
    required this.child,
    required this.onDelete,
  });

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<_SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
}

class _SwipeToDeleteItemState extends State<_SwipeToDeleteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  static const double _buttonSize = 52.0;
  static const double _revealWidth = _buttonSize + 16.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: _revealWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) return;
    if (details.primaryDelta! < 0 && _controller.value == 0) return;
    final delta = details.primaryDelta! / _revealWidth;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_controller.value > 0.4 || velocity > 300) {
      _controller.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  void _close() => _controller.animateTo(0.0, curve: Curves.easeOut);

  Future<void> _confirmDelete() async {
    _close();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: AppGlassDialog(
          title: 'حذف القائمة',
          message: 'هل أنت متأكد أنك تريد حذف هذه القائمة؟',
          primaryLabel: 'حذف',
          secondaryLabel: 'إلغاء',
          isPrimaryDestructive: true,
          onPrimaryPressed: () => Navigator.pop(ctx, true),
          onSecondaryPressed: () => Navigator.pop(ctx, false),
        ),
      ),
    );

    if (confirmed == true) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: _buttonSize,
                height: _buttonSize,
                child: GestureDetector(
                  onTap: _confirmDelete,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 0, 0),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(13),
                    child: Image.asset(
                      'assets/icons/trash.png',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: child,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
