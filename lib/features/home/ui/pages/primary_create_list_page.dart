import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/app_liquid_buttons.dart';
import 'package:tawakad_app/core/widgets/field_card.dart';
import 'package:tawakad_app/core/widgets/pop_up_list.dart';
import 'package:tawakad_app/features/home/ui/widgets/colors_picker.dart';
import 'package:tawakad_app/features/home/ui/widgets/icons_picker.dart';
import 'package:tawakad_app/core/widgets/glass_elements/favorite_button.dart';
import 'package:tawakad_app/features/home/model/pack_list.dart';
import 'package:tawakad_app/features/home/ui/pages/secondary_create_list_page.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/services/recommendation_service.dart';

class PrimaryCreateListPage extends StatefulWidget {
  final PackList? existing;

  const PrimaryCreateListPage({super.key, this.existing});

  @override
  State<PrimaryCreateListPage> createState() => _PrimaryCreateListPageState();
}

class _PrimaryCreateListPageState extends State<PrimaryCreateListPage> {
  final TextEditingController _nameController = TextEditingController();

  late Color _selectedColor;
  late String _selectedIcon;
  late bool _isFavorite;
  bool _nameInvalid = false;

  LocationResult _locationResult = LocationResult.empty();
  String? _selectedEvent;
  bool _eventRequired = false;
  bool _locationLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.title;
      _selectedColor = e.color;
      _selectedIcon = e.iconPath;
      _isFavorite = e.isFavorite;
      _selectedEvent = e.event;
      if (e.title.isNotEmpty) {
        _lookupLocation(e.title);
      }
    } else {
      _selectedColor = ColorPicker.colors[0];
      _selectedIcon = "assets/icons/icon_picker/1-logo.png";
      _isFavorite = false;
    }

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_nameInvalid) setState(() => _nameInvalid = false);

    _debounce?.cancel();
    final text = _nameController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _locationResult = LocationResult.empty();
        _selectedEvent = null;
        _eventRequired = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _lookupLocation(text);
    });
  }

  Future<void> _lookupLocation(String name) async {
    setState(() => _locationLoading = true);

    final result = await RecommendationService.instance.normalizeLocation(name);

    if (!mounted) return;
    setState(() {
      _locationLoading = false;
      _locationResult = result;
      if (_selectedEvent != null && !result.events.contains(_selectedEvent)) {
        _selectedEvent = null;
      }
    });
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  void _goToNextPage() {
    FocusScope.of(context).unfocus();

    final title = _nameController.text.trim();
    if (title.isEmpty) {
      setState(() => _nameInvalid = true);
      return;
    }
    setState(() => _nameInvalid = false);
    if (_locationResult.matched && _selectedEvent == null) {
      setState(() => _eventRequired = true);
      return;
    }
    setState(() => _eventRequired = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecondaryCreateListPage(
          title: title,
          iconPath: _selectedIcon,
          color: _selectedColor,
          isFavorite: _isFavorite,
          event: _selectedEvent,
          existing: widget.existing,
          canonicalLocation: _locationResult.canonical,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bgColor =
        _isDark ? AppDarkColors.background : const Color(0xFFF1F4F8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 24),
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
                _buildHeader(),
                const SizedBox(height: 22),
                _buildImageNameCard(),
                const SizedBox(height: 22),
                _buildEventSection(),
                const SizedBox(height: 22),
                _sectionTitle('لون القائمة'),
                _buildColorsCard(),
                const SizedBox(height: 22),
                _sectionTitle('أيقونة القائمة'),
                _buildIconsCard(),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventSection() {
    final hasEvents =
        _locationResult.matched && _locationResult.events.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _sectionTitle('حدث القائمة')),
              if (_locationLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 10),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _isDark
                          ? AppDarkColors.placeholder
                          : const Color(0xFF8A8A8E),
                    ),
                  ),
                ),
              if (_locationResult.matched && !_locationLoading)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 10),
                  child: _locationBadge(),
                ),
            ],
          ),
          if (hasEvents) ...[
            FieldCard(
              gap: 14,
              children: [
                GlassPopUpList(
                  title: _selectedEvent != null
                      ? (_locationResult.eventsArabic[_selectedEvent] ??
                          _selectedEvent!)
                      : 'اختر حدثاً',
                  options: _locationResult.events,
                  displayLabels: _locationResult.events
                      .map((e) => _locationResult.eventsArabic[e] ?? e)
                      .toList(),
                  initialValue: _selectedEvent ?? _locationResult.events.first,
                  onChanged: (v) => setState(() {
                    _selectedEvent = v;
                    _eventRequired = false;
                  }),
                  icon: Icons.flag_rounded,
                  circleColor: _eventRequired
                      ? const Color(0xFFE53935)
                      : const Color(0xFFC97070),
                ),
              ],
            ),
            if (_eventRequired) ...[
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الرجاء اختيار حدث للقائمة',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ] else if (!_locationLoading) ...[
            FieldCard(
              gap: 14,
              children: [
                _eventPlaceholderRow(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _locationBadge() {
    final canonical = _locationResult.canonical ?? '';
    const locationArabic = {
      'gym': 'صالة رياضية',
      'university': 'جامعة',
      'masjid_al_haram': 'المسجد الحرام',
      'travel': 'سفر',
    };

    final label = locationArabic[canonical] ?? canonical;
    final badgeBg = _isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9);
    final badgeText =
        _isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, size: 11, color: badgeText),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventPlaceholderRow() {
    final iconBg =
        _isDark ? AppDarkColors.fieldBorder : const Color(0xFFEFEFF4);
    final hintColor =
        _isDark ? AppDarkColors.placeholder : const Color(0xFFB2B2B8);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(Icons.flag_rounded, size: 16, color: hintColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'ستظهر الأحداث عند إدخال قائمة مدعومة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: hintColor, size: 20),
      ],
    );
  }

  Widget _buildHeader() {
    final closeBtnBg =
        _isDark ? AppDarkColors.surface : const Color(0xFFF0F0F3);
    final closeBtnIconColor = _isDark ? AppDarkColors.icon : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.existing != null ? 'تعديل القائمة' : 'إنشاء قائمة',
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

  Widget _buildImageNameCard() {
    final cardBg = _isDark ? AppDarkColors.surface : Colors.white;
    final fieldBg =
        _isDark ? AppDarkColors.fieldBorder : const Color(0xFFE7E7EA);
    final hintColor =
        _isDark ? AppDarkColors.placeholder : const Color(0xFFB2B2B8);
    final textColor = _isDark ? AppDarkColors.textPrimary : Colors.black87;

    return Container(
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'اسم القائمة',
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
        color: _isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
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
        color: _isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.25 : 0.06),
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
