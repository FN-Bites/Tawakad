import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/ble_scanning/model/ble_item.dart';
import 'package:tawakad_app/features/ble_scanning/provider/ble_item_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/pages/ble_reminder_page.dart';
import 'package:tawakad_app/features/ble_scanning/provider/map_ble_item_provider.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/ble_item/ble_device_card.dart';
import 'package:tawakad_app/features/ble_scanning/ui/widgets/map_ble_empty_state.dart';

const Duration kUiInterval = Duration(milliseconds: 800);

class MapBleItemPage extends StatefulWidget {
  final BleItem item;
  final String listId;
  final String checklistItemName;
  final VoidCallback? onItemSaved;
  final bool isEditing;

  const MapBleItemPage({
    super.key,
    required this.item,
    required this.listId,
    required this.checklistItemName,
    this.onItemSaved,
    this.isEditing = false,
  });

  @override
  State<MapBleItemPage> createState() => _MapBleItemPageState();
}

class _MapBleItemPageState extends State<MapBleItemPage> {
  String? _selectedId;
  bool _deviceInvalid = false;
  Timer? _uiTimer;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accent => widget.item.color;

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(kUiInterval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  void _proceed(MapBleItemProvider bleProvider) {
    if (_selectedId == null) {
      setState(() => _deviceInvalid = true);
      return;
    }
    bleProvider.stopScan();
    context.read<BleItemProvider>().mapItem(widget.item.name, _selectedId!);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BleReminderPage(
          item: widget.item.copyWith(
            deviceId: _selectedId,
            mappedDeviceId: _selectedId,
          ),
          listId: widget.listId,
          checklistItemName: widget.checklistItemName,
          onItemSaved: widget.onItemSaved,
          isEditing: widget.isEditing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = MapBleItemProvider();
        provider.reset();
        return provider;
      },
      child: Consumer<MapBleItemProvider>(
        builder: (context, bleProvider, _) {
          return _MapBleItemView(
            item: widget.item,
            isDark: _isDark,
            accent: _accent,
            bleProvider: bleProvider,
            selectedId: _selectedId,
            deviceInvalid: _deviceInvalid,
            onSelectDevice: (id) => setState(() {
              _selectedId = id;
              _deviceInvalid = false;
            }),
            onProceed: () => _proceed(bleProvider),
          );
        },
      ),
    );
  }
}

class _MapBleItemView extends StatelessWidget {
  final BleItem item;
  final bool isDark;
  final Color accent;
  final MapBleItemProvider bleProvider;
  final String? selectedId;
  final bool deviceInvalid;
  final ValueChanged<String> onSelectDevice;
  final VoidCallback onProceed;

  const _MapBleItemView({
    required this.item,
    required this.isDark,
    required this.accent,
    required this.bleProvider,
    required this.selectedId,
    required this.deviceInvalid,
    required this.onSelectDevice,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDark ? AppDarkColors.background : const Color(0xFFF1F4F8);
    final scanning = bleProvider.scanning;
    final isOn = bleProvider.isBluetoothOn;
    final devices = bleProvider.sortedDevices;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'ربط الإشارة',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppDarkColors.textPrimary : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleBtn(
                          icon: Icons.close_rounded,
                          iconColor:
                              isDark ? AppDarkColors.icon : Colors.black87,
                          bg: isDark
                              ? AppDarkColors.surface
                              : const Color(0xFFF0F0F3),
                          onTap: () => Navigator.maybePop(context),
                        ),
                        CircleBtn(
                          icon: Icons.check_rounded,
                          iconColor: Colors.white,
                          bg: selectedId != null
                              ? accent
                              : Colors.grey.shade400,
                          onTap: onProceed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: accent,
                      child: Image.asset(
                        item.iconPath,
                        width: 24,
                        height: 24,
                        color: Colors.white,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.category_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppDarkColors.textPrimary : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (selectedId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link_rounded, size: 14, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              'تم الاختيار',
                              style: TextStyle(
                                fontSize: 12,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: scanning
                          ? Colors.red.shade50
                          : isOn
                              ? accent.withOpacity(0.08)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scanning
                            ? Colors.red.shade300
                            : isOn
                                ? accent.withOpacity(0.3)
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isOn
                            ? (scanning
                                ? bleProvider.stopScan
                                : bleProvider.startScan)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (scanning) ...[
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'جارٍ المسح… اضغط للإيقاف',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ] else ...[
                                Icon(Icons.radar_rounded,
                                    color: isOn ? accent : Colors.grey),
                                const SizedBox(width: 10),
                                Text(
                                  isOn ? 'ابدأ المسح' : 'البلوتوث معطّل',
                                  style: TextStyle(
                                    color: isOn ? accent : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (deviceInvalid)
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 2),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'الرجاء اختيار جهاز أولاً',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: devices.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),
                          MapBleEmptyState(scanning: scanning),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: devices.length,
                        itemBuilder: (ctx, i) {
                          final d = devices[i];
                          return BleDeviceCard(
                            device: d,
                            isSelected: d.id == selectedId,
                            isDark: isDark,
                            accent: accent,
                            onTap: () => onSelectDevice(d.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final VoidCallback onTap;

  const CircleBtn({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
