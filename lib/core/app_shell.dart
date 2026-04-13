import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_nav_bar.dart';
import 'package:tawakad_app/core/widgets/glass_elements/glass_search_button.dart';
import 'package:tawakad_app/features/home/ui/pages/home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  String _searchQuery = '';
  late final AnimationController _navCtrl;
  late final Animation<Offset> _navSlide;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    super.dispose();
  }

  static const List<GlassNavItem> _items = [
    GlassNavItem(assetPath: 'assets/icons/nav_bar/home.png', label: 'الرئيسية'),
    GlassNavItem(
        assetPath: 'assets/icons/nav_bar/calender.png', label: 'التقويم'),
    GlassNavItem(assetPath: 'assets/icons/nav_bar/signal.png', label: 'المسح'),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _index == 0
        ? HomePage(searchQuery: _searchQuery)
        : _index == 1
            ? const _PlaceholderPage(label: 'التقويم')
            : const _PlaceholderPage(label: 'المسح');

    return Scaffold(
      extendBody: true,
      body: page,
      bottomNavigationBar: _SearchNavRow(
        navSlide: _navSlide,
        currentIndex: _index,
        items: _items,
        onNavTap: (i) => setState(() => _index = i),
        onSearchOpened: () => _navCtrl.forward(),
        onSearchClosed: () => _navCtrl.reverse(),
        onSearchChanged: (q) => setState(() => _searchQuery = q),
      ),
    );
  }
}

class _SearchNavRow extends StatelessWidget {
  final Animation<Offset> navSlide;
  final int currentIndex;
  final List<GlassNavItem> items;
  final ValueChanged<int> onNavTap;
  final VoidCallback onSearchOpened;
  final VoidCallback onSearchClosed;
  final ValueChanged<String> onSearchChanged;

  const _SearchNavRow({
    required this.navSlide,
    required this.currentIndex,
    required this.items,
    required this.onNavTap,
    required this.onSearchOpened,
    required this.onSearchClosed,
    required this.onSearchChanged,
  });

  static const double _sidePad = 20;
  static const double _rowGap = 10;
  static const double _rowHeight = 96.0;
  static const double _bottomPad = 16;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;
    const searchCollapsedW = 64.0;
    final navW = screenW - _sidePad * 2 - searchCollapsedW - _rowGap;

    return SizedBox(
      height: _rowHeight + _bottomPad + bottomInset,
      child: Padding(
        padding: EdgeInsets.only(
          left: _sidePad,
          right: _sidePad,
          bottom: _bottomPad + bottomInset,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GlassSearchButton(
                  onOpened: onSearchOpened,
                  onClosed: onSearchClosed,
                  onChanged: onSearchChanged,
                  hintText: '...ابحث',
                ),
              ),
              AnimatedBuilder(
                animation: navSlide,
                builder: (context, child) {
                  final t = navSlide.value.dx.clamp(0.0, 1.2) / 1.2;
                  final allocatedW = navW * (1.0 - t);
                  final gap = _rowGap * (1.0 - t);
                  return SizedBox(
                    width: (allocatedW + gap).clamp(0.0, navW + _rowGap),
                    child: Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: ClipRect(child: child),
                    ),
                  );
                },
                child: SlideTransition(
                  position: navSlide,
                  child: SizedBox(
                    width: navW,
                    child: GlassNavBar(
                      currentIndex: currentIndex,
                      onTap: onNavTap,
                      items: items,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: const TextStyle(fontSize: 24, fontFamily: 'Cairo')),
    );
  }
}
