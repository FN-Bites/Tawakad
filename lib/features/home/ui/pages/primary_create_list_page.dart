import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';
import 'package:tawakad_app/core/widgets/pop_up_list.dart';
import 'package:tawakad_app/features/home/ui/widgets/colors_picker.dart';
import 'package:tawakad_app/features/home/ui/widgets/icons_picker.dart';
import 'package:tawakad_app/core/widgets/glass_elements/favorite_button.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/ui/pages/secondary_create_list_page.dart';

class PrimaryCreateListPage extends StatefulWidget {
  final PackList? existing;

  const PrimaryCreateListPage({super.key, this.existing});

  @override
  State<PrimaryCreateListPage> createState() => _PrimaryCreateListPageState();
}

class _PrimaryCreateListPageState extends State<PrimaryCreateListPage> {
  final TextEditingController _nameController = TextEditingController();

  late String _selectedEvent;
  late Color _selectedColor;
  late String _selectedIcon;
  late bool _isFavorite;
  bool _nameInvalid = false;

  final List<String> _eventOptions = ['لايوجد شيء', 'برزنتشين', 'اختبار'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.title;
      _selectedColor = e.color;
      _selectedIcon = e.iconPath;
      _isFavorite = e.isFavorite;
      _selectedEvent = (e.event != null && _eventOptions.contains(e.event))
          ? e.event!
          : _eventOptions.first;
    } else {
      _selectedEvent = _eventOptions.first;
      _selectedColor = ColorPicker.colors[0];
      _selectedIcon = "assets/icons/icon_picker/1-logo.png";
      _isFavorite = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    FocusScope.of(context).unfocus();
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      setState(() => _nameInvalid = true);
      return;
    }
    setState(() => _nameInvalid = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecondaryCreateListPage(
          title: title,
          iconPath: _selectedIcon,
          color: _selectedColor,
          isFavorite: _isFavorite,
          event: _selectedEvent == _eventOptions.first ? null : _selectedEvent,
          existing: widget.existing,
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
                _buildHeader(),
                const SizedBox(height: 22),
                _buildImageNameCard(),
                const SizedBox(height: 22),
                FieldCard(
                  gap: 14,
                  children: [
                    GlassPopUpList(
                      title: 'الحدث',
                      options: _eventOptions,
                      initialValue: _selectedEvent,
                      onChanged: (v) => setState(() => _selectedEvent = v),
                      icon: Icons.flag_rounded,
                      circleColor: const Color(0xFFC97070),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildColorsCard(),
                const SizedBox(height: 22),
                _buildIconsCard(),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.existing != null ? 'تعديل القائمة' : 'إنشاء قائمة',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                child: const CustomPaint(
                  size: Size(22, 22),
                  painter: BoldIconPainter(
                    icon: Icons.close_rounded,
                    color: Colors.black87,
                    size: 22,
                    strokeExtra: 1.2,
                  ),
                ),
                onTap: () => Navigator.maybePop(context),
                backgroundColor: const Color(0xFFF0F0F3),
              ),
              Row(
                children: [
                  FavoriteToggleButton(
                    isFavorite: _isFavorite,
                    onToggle: () => setState(() => _isFavorite = !_isFavorite),
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
                    onTap: _goToNextPage,
                    backgroundColor: const Color(0xFF1F8EFA),
                  ),
                ],
              ),
            ],
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

  Widget _buildImageNameCard() {
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
              radius: 72,
              backgroundColor: _selectedColor,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  _selectedIcon,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.list_alt_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                onChanged: (_) {
                  if (_nameInvalid) setState(() => _nameInvalid = false);
                },
                decoration: InputDecoration(
                  hintText: 'اسم القائمة',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB2B2B8),
                  ),
                  filled: true,
                  fillColor: _nameInvalid
                      ? const Color(0xFFFFECEC)
                      : const Color(0xFFE7E7EA),
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
                        ? const BorderSide(color: Color(0xFFE53935), width: 1.5)
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
                      'الرجاء ادخال اسم القائمة',
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
        ],
      ),
    );
  }

  Widget _buildColorsCard() {
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
        onColorSelected: (c) => setState(() => _selectedColor = c),
      ),
    );
  }

  Widget _buildIconsCard() {
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
          onIconSelected: (p) => setState(() => _selectedIcon = p),
        ),
      ),
    );
  }
}
