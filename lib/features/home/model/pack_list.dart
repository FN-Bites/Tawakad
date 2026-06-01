import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Shared UUID generator used to create unique IDs for new pack lists
const _uuid = Uuid();

// Data model that represents a user's packing list
class PackList {
  final String id;
  final String userId;
  final String title;
  final String iconPath;
  final int colorValue;
  final List<String> items;
  final Set<int> checkedIndices;
  final DateTime? date;
  final String? time;
  final String? event;
  final bool repeat;
  final List<int> repeatDays;
  final bool isShared;
  final DateTime createdAt;
  final bool isFavorite;

  const PackList({
    required this.id,
    required this.userId,
    required this.title,
    required this.iconPath,
    required this.colorValue,
    required this.items,
    this.checkedIndices = const {},
    this.date,
    this.time,
    this.event,
    this.repeat = false,
    this.repeatDays = const [],
    this.isShared = false,
    required this.createdAt,
    this.isFavorite = false,
  });

// Helper getters for item count, color conversion, and completion status
  int get itemCount => items.length;
  Color get color => Color(colorValue);
  bool get isCompleted =>
      items.isNotEmpty && checkedIndices.length == items.length;

// Equality is based on the list ID to compare PackList objects correctly
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PackList && other.id == id);

  @override
  int get hashCode => id.hashCode;

// Factory constructor used when creating a new pack list inside the app
  factory PackList.create({
    required String userId,
    required String title,
    required String iconPath,
    required Color color,
    List<String> items = const [],
    Set<int> checkedIndices = const {},
    DateTime? date,
    String? time,
    String? event,
    bool repeat = false,
    List<int> repeatDays = const [],
    bool isShared = false,
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    return PackList(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      iconPath: iconPath,
      colorValue: color.value,
      items: items,
      checkedIndices: checkedIndices,
      date: date,
      time: time,
      event: event,
      repeat: repeat,
      repeatDays: repeatDays,
      isShared: isShared,
      createdAt: now,
      isFavorite: isFavorite,
    );
  }
// Creates an updated copy of the current pack list without changing the original object
  PackList copyWith({
    String? title,
    String? iconPath,
    int? colorValue,
    List<String>? items,
    Set<int>? checkedIndices,
    DateTime? date,
    String? time,
    String? event,
    bool? repeat,
    List<int>? repeatDays,
    bool? isShared,
    bool? isFavorite,
  }) {
    return PackList(
      id: id,
      userId: userId,
      title: title ?? this.title,
      iconPath: iconPath ?? this.iconPath,
      colorValue: colorValue ?? this.colorValue,
      items: items ?? this.items,
      checkedIndices: checkedIndices ?? this.checkedIndices,
      date: date ?? this.date,
      time: time ?? this.time,
      event: event ?? this.event,
      repeat: repeat ?? this.repeat,
      repeatDays: repeatDays ?? this.repeatDays,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

// Converts the PackList object into a map format suitable for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'iconPath': iconPath,
      'colorValue': colorValue,
      'items': items,
      'checkedIndices': checkedIndices.toList(),
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'time': time,
      'event': event,
      'repeat': repeat,
      'repeatDays': repeatDays,
      'isShared': isShared,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
    };
  }

  factory PackList.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return PackList(
      id: map['id'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? 'بدون عنوان',
      iconPath: map['iconPath'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFF2196F3,
      items:
          map['items'] != null ? List<String>.from(map['items'] as List) : [],
      checkedIndices: map['checkedIndices'] != null
          ? Set<int>.from(map['checkedIndices'] as List)
          : {},
      date: parseDate(map['date']),
      time: map['time'] as String?,
      event: map['event'] as String?,
      repeat: map['repeat'] as bool? ?? false,
      repeatDays: map['repeatDays'] != null
          ? List<int>.from(map['repeatDays'] as List)
          : [],
      isShared: map['isShared'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
