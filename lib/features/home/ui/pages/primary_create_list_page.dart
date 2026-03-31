import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';

// عدّلي المسارات حسب مكان الملفات عندك
import 'package:tawakad_app/core/widgets/field_card.dart';
import 'package:tawakad_app/core/widgets/toggle_button.dart';
import 'package:tawakad_app/core/widgets/pop_up_list.dart';
import 'package:tawakad_app/features/home/ui/widgets/colors_picker.dart';
import 'package:tawakad_app/features/home/ui/widgets/image_name_list.dart';
import 'package:tawakad_app/features/home/ui/widgets/icons_picker.dart';
import 'package:tawakad_app/features/home/ui/widgets/items_list.dart';

class PrimaryCreateListPage extends StatefulWidget {
  const PrimaryCreateListPage({super.key});

  @override
  State<PrimaryCreateListPage> createState() => _PrimaryCreateListPage();
}

class _PrimaryCreateListPage extends State<PrimaryCreateListPage> {
  final TextEditingController _nameController = TextEditingController();

  late String _selectedCreationType;
  late String _selectedCategory;
  late String _selectedEvent;
  late Color _selectedColor;
  late String _selectedIcon;

  final List<String> _creationOptions = ['يدوي', 'تلقائي'];
  final List<String> _categoryOptions = [
    'المفضلة',
    'الدراسة',
    'العمل',
    'السفر'
  ];
  final List<String> _eventOptions = ['لايوجد شيء', 'جامعة', 'موعد', 'رحلة'];

  @override
  void initState() {
    super.initState();
    _selectedCreationType = _creationOptions.first;
    _selectedCategory = _categoryOptions.first;
    _selectedEvent = _eventOptions.first;
    _selectedColor = ColorPicker.colors[0];
    _selectedIcon = "assets/Icons/list.bullet.png";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveList() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          _nameController.text.trim().isEmpty
              ? 'اكتبي اسم القائمة أولًا'
              : 'تم حفظ القائمة',
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
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
                    color: const Color(0xFFCFCFD4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _headerCircleButton(
                        child: const Icon(
                          Icons.close_rounded,
                          size: 28,
                          color: Colors.black87,
                        ),
                        onTap: () => Navigator.maybePop(context),
                        backgroundColor: const Color(0xFFF7F7F8),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'إنشاء قائمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      _headerCircleButton(
                        child: const Icon(
                          Icons.check_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        onTap: _saveList,
                        backgroundColor: const Color(0xFF1F8EFA),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _imageNameCard(),
                const SizedBox(height: 22),
                FieldCard(
                  gap: 14,
                  children: [
                    PopUpList(
                      title: 'طريقة الإنشاء',
                      options: _creationOptions,
                      initialValue: _selectedCreationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedCreationType = value;
                        });
                      },
                      icon: Icons.edit_rounded,
                      circleColor: const Color(0xFFF3A754),
                    ),
                    PopUpList(
                      title: 'الفئات',
                      options: _categoryOptions,
                      initialValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      icon: Icons.sell_rounded,
                      circleColor: const Color(0xFF6B67C8),
                    ),
                    PopUpList(
                      title: 'الحدث',
                      options: _eventOptions,
                      initialValue: _selectedEvent,
                      onChanged: (value) {
                        setState(() {
                          _selectedEvent = value;
                        });
                      },
                      icon: Icons.flag_rounded,
                      circleColor: const Color(0xFFC97070),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _colorsCard(),
                const SizedBox(height: 22),
                _iconsCard(),
                const SizedBox(height: 24),
                AppLiquidButtons.primary(
                  label: 'إنشاء القائمة',
                  onPressed: _saveList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageNameCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
              radius: 54,
              backgroundColor: _selectedColor,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  _selectedIcon,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.list_alt_rounded,
                      color: Colors.white,
                      size: 46,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'اسم القائمة',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB2B2B8),
              ),
              filled: true,
              fillColor: const Color(0xFFE7E7EA),
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
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: _selectedColor.withOpacity(0.75),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ColorPicker(
        selectedColor: _selectedColor,
        onColorSelected: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
      ),
    );
  }

  Widget _iconsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: IconsPicker(
          selectedIcon: _selectedIcon,
          onIconSelected: (iconPath) {
            setState(() {
              _selectedIcon = iconPath;
            });
          },
        ),
      ),
    );
  }

  Widget _headerCircleButton({
    required Widget child,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
