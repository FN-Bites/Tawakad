import 'package:flutter/material.dart';

const double kRssiAlpha = 0.30;
const Duration kFreshWindow = Duration(seconds: 6);
const int kPresenceRssi = -65;

class BleItem {
  final String deviceId;
  final String name;
  final int rssi;
  final double smoothedRssi;
  final DateTime lastSeen;
  final bool isFavorite;
  final String iconPath;
  final int colorValue;
  final int? reminderMinutesBefore;
  final String? mappedDeviceId;
  final List<String> listIds;

  const BleItem({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.smoothedRssi,
    required this.lastSeen,
    this.isFavorite = false,
    this.iconPath = '',
    this.colorValue = 0xFF1F8EFA,
    this.reminderMinutesBefore,
    this.mappedDeviceId,
    this.listIds = const [],
  });

  Color get color => Color(colorValue);

  bool isPresent(DateTime now) {
    final fresh = now.difference(lastSeen) <= kFreshWindow;
    final close = smoothedRssi >= kPresenceRssi;
    return fresh && close;
  }

  BleItem copyWith({
    String? deviceId,
    String? name,
    int? rssi,
    double? smoothedRssi,
    DateTime? lastSeen,
    bool? isFavorite,
    String? iconPath,
    int? colorValue,
    int? reminderMinutesBefore,
    String? mappedDeviceId,
    List<String>? listIds,
  }) {
    return BleItem(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      smoothedRssi: smoothedRssi ?? this.smoothedRssi,
      lastSeen: lastSeen ?? this.lastSeen,
      isFavorite: isFavorite ?? this.isFavorite,
      iconPath: iconPath ?? this.iconPath,
      colorValue: colorValue ?? this.colorValue,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      mappedDeviceId: mappedDeviceId ?? this.mappedDeviceId,
      listIds: listIds ?? this.listIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'name': name,
        'rssi': rssi,
        'smoothedRssi': smoothedRssi,
        'lastSeen': lastSeen.toIso8601String(),
        'isFavorite': isFavorite,
        'iconPath': iconPath,
        'colorValue': colorValue,
        'reminderMinutesBefore': reminderMinutesBefore,
        'mappedDeviceId': mappedDeviceId,
        'listIds': listIds,
      };

  factory BleItem.fromMap(Map<String, dynamic> map) => BleItem(
        deviceId: map['deviceId'] as String,
        name: map['name'] as String,
        rssi: map['rssi'] as int,
        smoothedRssi: (map['smoothedRssi'] as num).toDouble(),
        lastSeen: DateTime.parse(map['lastSeen'] as String),
        isFavorite: map['isFavorite'] as bool? ?? false,
        iconPath: map['iconPath'] as String? ?? '',
        colorValue: map['colorValue'] as int? ?? 0xFF1F8EFA,
        reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
        mappedDeviceId: map['mappedDeviceId'] as String?,
        listIds: map['listIds'] != null
            ? List<String>.from(map['listIds'] as List)
            : [],
      );
}
