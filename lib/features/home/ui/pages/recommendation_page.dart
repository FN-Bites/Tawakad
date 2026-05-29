import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tawakad_app/features/home/model/item_sections.dart';
import 'package:tawakad_app/core/services/recommendation_service.dart';
import 'package:tawakad_app/core/services/weather_service.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_back_button.dart';

import '../widgets/mascot_loading.dart';
import '../widgets/recommendation_mascot_header.dart';
import '../widgets/recommendation_row.dart';
import '../widgets/retry_button.dart';

class RecommendationPage extends StatefulWidget {
  final String listName;
  final String event;
  final void Function(String arabicItem) onAddItem;
  final void Function(String arabicItem)? onRemoveItem;
  final List<String> existingItems;
  final DateTime? eventDate;

  const RecommendationPage({
    super.key,
    required this.listName,
    required this.event,
    required this.onAddItem,
    this.onRemoveItem,
    this.existingItems = const [],
    this.eventDate,
  });

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  String _gender = 'male';
  String _userStatus = '';
  String _weather = 'sunny';

  static String _getCurrentPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'night';
  }

  String get _role {
    final location = widget.listName;
    if (location == 'gym') return 'gym_user';
    if (location == 'masjid_al_haram') return 'pilgrim';
    if (location == 'travel') return 'traveler';
    if (location == 'university') {
      if (_userStatus == 'student') return 'student';
      if (_userStatus == 'employee') return 'professor';
      return 'student';
    }
    return 'student';
  }

  List<RecommendedItem> _items = [];
  bool _loading = true;
  bool _minTimeElapsed = false;
  String? _error;
  Future<void>? _fetchFuture;
  final Set<String> _addedThisSession = {};

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _addedThisSession.addAll(widget.existingItems);
    _fetchFuture = _loadProfileThenFetch();
  }

  Future<void> _loadProfileThenFetch() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (doc.exists && mounted) {
          final data = doc.data()!;
          final gender = (data['gender'] as String?)?.toLowerCase();
          final status = (data['status'] as String?)?.toLowerCase();
          final answers = List<String>.from(data['answers'] ?? []);
          setState(() {
            _gender = gender ??
                (answers.length > 2 ? answers[2].toLowerCase() : 'male');
            _userStatus =
                status ?? (answers.length > 3 ? answers[3].toLowerCase() : '');
          });
        }
      }
    } catch (_) {}

    try {
      final targetDate = widget.eventDate ?? DateTime.now();
      final fetchedWeather =
          await WeatherService.instance.getWeatherForDate(targetDate);
      if (mounted) setState(() => _weather = fetchedWeather);
    } catch (_) {}

    if (_getCurrentPeriod() == 'night' && _weather == 'sunny') {
      _weather = 'warm';
    }

    await _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _minTimeElapsed = false;
      _error = null;
    });

    final results = await RecommendationService.instance.getRecommendations(
      listName: widget.listName,
      event: widget.event,
      period: _getCurrentPeriod(),
      weather: _weather,
      gender: _gender,
      role: _role,
      topN: 20,
    );

    if (!mounted) return;

    if (results.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'لم نتمكن من جلب الاقتراحات، حاول مجدداً.';
      });
    } else {
      setState(() {
        _loading = false;
        _items = results;
      });
    }
  }

  void _handleAdd(RecommendedItem item) {
    if (_addedThisSession.contains(item.arabic)) return;
    setState(() => _addedThisSession.add(item.arabic));
    widget.onAddItem(item.arabic);
  }

  void _handleRemove(RecommendedItem item) {
    if (!_addedThisSession.contains(item.arabic)) return;
    setState(() => _addedThisSession.remove(item.arabic));
    widget.onRemoveItem?.call(item.arabic);
  }

  List<String> _prioritySections() {
    const roleFirst = <String, List<String>>{
      'gym_user': ['الرياضة والتمارين', 'الأكل والشرب', 'العناية والنظافة'],
      'pilgrim': ['العبادة والحرم', 'الأكل والشرب', 'العناية والنظافة'],
      'traveler': ['السفر والتنقل', 'الأكل والشرب', 'العناية والنظافة'],
      'student': [
        'الدراسة والعمل',
        'الإلكترونيات والشواحن',
        'العناية والنظافة',
      ],
      'professor': [
        'الدراسة والعمل',
        'الإلكترونيات والشواحن',
        'العناية والنظافة',
      ],
    };

    const rest = [
      'اقتراحات حسب الطقس',
      'ملابس وإكسسوارات',
      'الحقائب والتخزين',
      'الصحة والسلامة',
      'السفر والتنقل',
      'الأكل والشرب',
      'الإلكترونيات والشواحن',
      'الدراسة والعمل',
      'العناية والنظافة',
      'العبادة والحرم',
      'الرياضة والتمارين',
    ];

    final priority = roleFirst[_role] ?? [];
    final ordered = [...priority];
    for (final s in rest) {
      if (!ordered.contains(s)) ordered.add(s);
    }
    return ordered;
  }

  List<MapEntry<String, List<RecommendedItem>>> _buildSections() {
    final grouped = <String, List<RecommendedItem>>{};

    for (final item in _items) {
      final section =
          itemSections[item.english.toLowerCase()] ?? 'اقتراحات عامة';
      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(item);
    }

    final sections = <MapEntry<String, List<RecommendedItem>>>[];

    for (final title in _prioritySections()) {
      if (grouped.containsKey(title)) {
        sections.add(MapEntry(title, grouped[title]!));
        grouped.remove(title);
      }
    }

    for (final entry in grouped.entries) {
      sections.add(entry);
    }

    return sections;
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const GlassBackButton(),
          Text(
            'اقتراحات ذكية',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _isDark ? AppDarkColors.textPrimary : null,
                ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading || !_minTimeElapsed) {
      return MascotLoading(
        workFuture: _fetchFuture,
        onDone: () {
          if (mounted) setState(() => _minTimeElapsed = true);
        },
      );
    }
    if (_error != null) return _buildError();
    return _buildList();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color:
                  _isDark ? AppDarkColors.placeholder : const Color(0xFFB2B2B8),
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _isDark
                        ? AppDarkColors.placeholder
                        : const Color(0xFF8A8A8E),
                  ),
            ),
            const SizedBox(height: 20),
            RetryButton(onTap: _fetch),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final sections = _buildSections();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: 1 + sections.length * 2,
      itemBuilder: (context, index) {
        if (index == 0) return const RecommendationMascotHeader();

        final sectionIndex = (index - 1) ~/ 2;
        final isHeader = (index - 1) % 2 == 0;
        final section = sections[sectionIndex];

        if (isHeader) return _buildSectionHeader(section.key);
        return _buildSectionCard(section.value);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, right: 4),
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _isDark ? AppDarkColors.placeholder : const Color(0xFF8A8A8E),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<RecommendedItem> sectionItems) {
    final cardBg = _isDark ? AppDarkColors.surface : Colors.white;
    final dividerColor = _isDark
        ? AppDarkColors.fieldBorder.withOpacity(0.5)
        : const Color(0xFFEEEEF2);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.22 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < sectionItems.length; i++) ...[
            RecommendationRow(
              item: sectionItems[i],
              alreadyAdded: _addedThisSession.contains(sectionItems[i].arabic),
              isDark: _isDark,
              onAdd: () => _handleAdd(sectionItems[i]),
              onRemove: () => _handleRemove(sectionItems[i]),
            ),
            if (i < sectionItems.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
                indent: 56,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}
