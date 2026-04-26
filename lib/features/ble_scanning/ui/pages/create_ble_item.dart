import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/glass_elements/favorite_button.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/color_picker.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/icon_picker.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';
import 'map_ble_item_page.dart';

class CreateBleItemPage extends StatefulWidget {
  final VoidCallback? onItemSaved;
  final BleItem? existing;

  const CreateBleItemPage({
    super.key,
    this.onItemSaved,
    this.existing,
  });

  @override
  State<CreateBleItemPage> createState() => _CreateBleItemPageState();
}

class _CreateBleItemPageState extends State<CreateBleItemPage> {
  final TextEditingController _nameController = TextEditingController();
  late Color _selectedColor;
  late String _selectedIcon;
  late bool _isFavorite;
  bool _nameInvalid = false;
  bool _listInvalid = false;
  final List<PackList> _selectedLists = [];

  bool get _isEditing => widget.existing != null;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _selectedColor = e.color;
      _selectedIcon = e.iconPath;
      _isFavorite = e.isFavorite;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final allLists = context.read<PackListProvider>().lists;
        setState(() {
          _selectedLists.clear();
          _selectedLists.addAll(
            allLists.where((l) => e.listIds.contains(l.id)),
          );
        });
      });
    } else {
      _selectedColor = BleColorsPicker.colors[0];
      _selectedIcon = BleIconsPicker.icons[0];
      _isFavorite = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleList(PackList list) {
    setState(() {
      if (_selectedLists.any((l) => l.id == list.id)) {
        _selectedLists.removeWhere((l) => l.id == list.id);
      } else {
        _selectedLists.add(list);
      }
      if (_selectedLists.isNotEmpty) _listInvalid = false;
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    setState(() {
      _nameInvalid = name.isEmpty;
      _listInvalid = _selectedLists.isEmpty;
    });
    if (_nameInvalid || _listInvalid) return;

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        name: name,
        iconPath: _selectedIcon,
        colorValue: _selectedColor.value,
        isFavorite: _isFavorite,
        listIds: _selectedLists.map((l) => l.id).toList(),
      );
      context.read<BleItemProvider>().updateSavedItem(updated);

      final packListProvider = context.read<PackListProvider>();
      final oldListIds = widget.existing!.listIds.toSet();
      final newListIds = _selectedLists.map((l) => l.id).toSet();

      for (final listId in newListIds.difference(oldListIds)) {
        packListProvider.addItem(listId, name);
      }
      for (final listId in oldListIds.difference(newListIds)) {
        packListProvider.removeItem(listId, widget.existing!.name);
      }

      final listId = _selectedLists.first.id;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MapBleItemPage(
            item: updated,
            listId: listId,
            checklistItemName: name,
            onItemSaved: widget.onItemSaved,
            isEditing: true,
          ),
        ),
      );
    } else {
      final packListProvider = context.read<PackListProvider>();
      for (final list in _selectedLists) {
        packListProvider.addItem(list.id, name);
      }

      final newItem = BleItem(
        deviceId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        rssi: 0,
        smoothedRssi: 0,
        lastSeen: DateTime.now(),
        iconPath: _selectedIcon,
        colorValue: _selectedColor.value,
        isFavorite: _isFavorite,
        listIds: _selectedLists.map((l) => l.id).toList(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapBleItemPage(
            item: newItem,
            listId: _selectedLists.first.id,
            checklistItemName: name,
            onItemSaved: widget.onItemSaved,
          ),
        ),
      );
    }
  }

  Widget _sectionTitle(String text) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 10),
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isDark
                    ? AppDarkColors.placeholder
                    : const Color(0xFF8A8A8E),
              ),
        ),
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
              color: Colors.black.withOpacity(_isDark ? 0.3 : 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildListsSection(
    List<PackList> lists,
    Color cardBg,
    Color hintColor,
    Color textColor,
  ) {
    return Column(
      children: [
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'أضف إلى قوائم',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isDark
                        ? AppDarkColors.placeholder
                        : const Color(0xFF8A8A8E),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 10),
            child: Text(
              'تُعرض فقط القوائم ذات الوقت المحدد، لأن المسح التلقائي يعتمد عليه.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: hintColor),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: _listInvalid
                ? Border.all(color: const Color(0xFFE53935), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: lists.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'لا توجد قوائم بوقت محدد بعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: hintColor, fontSize: 14),
                  ),
                )
              : Column(
                  children: lists.asMap().entries.map((entry) {
                    final i = entry.key;
                    final list = entry.value;
                    final isChecked =
                        _selectedLists.any((l) => l.id == list.id);
                    final isLast = i == lists.length - 1;

                    return InkWell(
                      onTap: () => _toggleList(list),
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? const Radius.circular(24) : Radius.zero,
                        bottom:
                            isLast ? const Radius.circular(24) : Radius.zero,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? list.color
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: isChecked
                                          ? list.color
                                          : _isDark
                                              ? AppDarkColors.placeholder
                                              : const Color(0xFFB2B2B8),
                                      width: 1.8,
                                    ),
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: list.color,
                                  child: Image.asset(
                                    list.iconPath,
                                    width: 18,
                                    height: 18,
                                    color: Colors.white,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    list.title,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: _isDark
                                  ? AppDarkColors.fieldBorder
                                  : const Color(0xFFEEEEF0),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        if (_listInvalid) ...[
          const SizedBox(height: 6),
          const SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'الرجاء اختيار قائمة واحدة على الأقل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLists = context.watch<PackListProvider>().lists;
    final lists = allLists.where((l) => l.time != null).toList();
    final validIds = lists.map((l) => l.id).toSet();
    _selectedLists.removeWhere((l) => !validIds.contains(l.id));

    final bgColor =
        _isDark ? AppDarkColors.background : const Color(0xFFF1F4F8);
    final cardBg = _isDark ? AppDarkColors.surface : Colors.white;
    final fieldBg =
        _isDark ? AppDarkColors.fieldBorder : const Color(0xFFE7E7EA);
    final hintColor =
        _isDark ? AppDarkColors.placeholder : const Color(0xFFB2B2B8);
    final textColor = _isDark ? AppDarkColors.textPrimary : Colors.black87;
    final closeBtnBg =
        _isDark ? AppDarkColors.surface : const Color(0xFFF0F0F3);
    final closeBtnIconColor = _isDark ? AppDarkColors.icon : Colors.black87;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _isDark
                        ? AppDarkColors.fieldBorder
                        : const Color(0xFFCFCFD4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        _isEditing ? 'تعديل الغرض' : 'إضافة غرض',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _isDark ? AppDarkColors.textPrimary : null,
                            ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleButton(
                            child: CustomPaint(
                              size: const Size(22, 22),
                              painter: BoldIconPainter(
                                icon: Icons.close_rounded,
                                color: closeBtnIconColor,
                                size: 22,
                                strokeExtra: 1.2,
                              ),
                            ),
                            onTap: () => Navigator.maybePop(context),
                            backgroundColor: closeBtnBg,
                          ),
                          Row(
                            children: [
                              FavoriteToggleButton(
                                isFavorite: _isFavorite,
                                onToggle: () =>
                                    setState(() => _isFavorite = !_isFavorite),
                              ),
                              const SizedBox(width: 10),
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
                                onTap: _submit,
                                backgroundColor: const Color(0xFF1F8EFA),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isDark ? 0.25 : 0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _selectedColor.withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 72,
                          backgroundColor: _selectedColor,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              _selectedIcon,
                              width: 96,
                              height: 96,
                              fit: BoxFit.contain,
                              color: Colors.white,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.category_rounded,
                                color: Colors.white,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        onChanged: (_) {
                          if (_nameInvalid) {
                            setState(() => _nameInvalid = false);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'اسم الغرض',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: _nameInvalid
                              ? (_isDark
                                  ? const Color(0xFF3B1A1A)
                                  : const Color(0xFFFFECEC))
                              : fieldBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: _nameInvalid
                                ? const BorderSide(
                                    color: Color(0xFFE53935), width: 1.5)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: _nameInvalid
                                  ? const Color(0xFFE53935)
                                  : _selectedColor.withOpacity(0.75),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      if (_nameInvalid) ...[
                        const SizedBox(height: 6),
                        const SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'الرجاء ادخال اسم الغرض',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildListsSection(lists, cardBg, hintColor, textColor),
                const SizedBox(height: 22),
                _sectionTitle('لون الغرض'),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: BleColorsPicker(
                    selectedColor: _selectedColor,
                    onColorSelected: (c) => setState(() => _selectedColor = c),
                  ),
                ),
                const SizedBox(height: 22),
                _sectionTitle('أيقونة الغرض'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: BleIconsPicker(
                    selectedIcon: _selectedIcon,
                    onIconSelected: (p) => setState(() => _selectedIcon = p),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
