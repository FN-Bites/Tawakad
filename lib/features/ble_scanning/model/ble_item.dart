import 'package:flutter/material.dart';

const double kRssiAlpha = 0.30;
const Duration kFreshWindow = Duration(seconds: 8);
const int kPresenceRssi = -80;

class BleItem {
  final String deviceId;
  final String name;
  final int rssi;
  final double smoothedRssi;
  final DateTime lastSeen;
  final String iconPath;
  final int colorValue;
  final bool isFavorite;

  const BleItem({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.smoothedRssi,
    required this.lastSeen,
    required this.iconPath,
    required this.colorValue,
    this.isFavorite = false,
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
    String? iconPath,
    int? colorValue,
    bool? isFavorite,
  }) {
    return BleItem(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      smoothedRssi: smoothedRssi ?? this.smoothedRssi,
      lastSeen: lastSeen ?? this.lastSeen,
      iconPath: iconPath ?? this.iconPath,
      colorValue: colorValue ?? this.colorValue,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'name': name,
        'rssi': rssi,
        'smoothedRssi': smoothedRssi,
        'lastSeen': lastSeen.toIso8601String(),
        'iconPath': iconPath,
        'colorValue': colorValue,
        'isFavorite': isFavorite,
      };

  factory BleItem.fromMap(Map<String, dynamic> map) => BleItem(
        deviceId: map['deviceId'] as String,
        name: map['name'] as String,
        rssi: map['rssi'] as int,
        smoothedRssi: (map['smoothedRssi'] as num).toDouble(),
        lastSeen: DateTime.parse(map['lastSeen'] as String),
        iconPath: map['iconPath'] as String,
        colorValue: map['colorValue'] as int,
        isFavorite: map['isFavorite'] as bool? ?? false,
      );
}
