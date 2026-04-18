import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/color_picker.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/icon_picker.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/provider/pack_list_provider.dart';

class CreateBleItemPage extends StatefulWidget {
  const CreateBleItemPage({super.key});

  @override
  State<CreateBleItemPage> createState() => _CreateBleItemPageState();
}

class _CreateBleItemPageState extends State<CreateBleItemPage> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = BleColorsPicker.colors[0];
  String _selectedIcon = BleIconsPicker.icons[0];
  bool _nameInvalid = false;
  bool _listInvalid = false;
  PackList? _selectedList;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    setState(() {
      _nameInvalid = name.isEmpty;
      _listInvalid = _selectedList == null;
    });
    if (_nameInvalid || _listInvalid) return;

    context.read<PackListProvider>().addItem(_selectedList!.id, name);

    context.read<BleProvider>().addSavedItem(
          BleItem(
            deviceId: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            rssi: 0,
            smoothedRssi: 0,
            lastSeen: DateTime.now(),
            iconPath: _selectedIcon,
            colorValue: _selectedColor.value,
          ),
        );

    Navigator.maybePop(context);
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
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

  @override
  Widget build(BuildContext context) {
    final lists = context.watch<PackListProvider>().lists;

    if (_selectedList != null && !lists.any((l) => l.id == _selectedList!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedList = null);
      });
    }

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
                        'إضافة غرض',
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
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              'الرجاء ادخال اسم الغرض',
                              textDirection: TextDirection.rtl,
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
                const SizedBox(height: 22),
                _sectionTitle('أضف إلى قائمة'),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'لا توجد قوائم بعد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: hintColor,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<PackList>(
                            value: lists.any((l) => l.id == _selectedList?.id)
                                ? _selectedList
                                : null,
                            isExpanded: true,
                            hint: Text(
                              'اختر قائمة',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: _listInvalid
                                    ? const Color(0xFFE53935)
                                    : hintColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            dropdownColor: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _listInvalid
                                  ? const Color(0xFFE53935)
                                  : hintColor,
                            ),
                            items: lists.map((list) {
                              return DropdownMenuItem<PackList>(
                                value: list,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: list.color,
                                      child: Image.asset(
                                        list.iconPath,
                                        width: 16,
                                        height: 16,
                                        color: Colors.white,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      list.title,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() {
                              _selectedList = v;
                              _listInvalid = false;
                            }),
                          ),
                        ),
                ),
                if (_listInvalid) ...[
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        'الرجاء اختيار قائمة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
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
