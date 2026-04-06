import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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

  int get itemCount => items.length;
  Color get color => Color(colorValue);

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'iconPath': iconPath,
      'colorValue': colorValue,
      'items': items,
      'checkedIndices': checkedIndices.toList(),
      'date': date?.toIso8601String(),
      'time': time,
      'event': event,
      'repeat': repeat,
      'repeatDays': repeatDays,
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory PackList.fromMap(Map<String, dynamic> map) {
    return PackList(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      iconPath: map['iconPath'] as String,
      colorValue: map['colorValue'] as int,
      items: List<String>.from(map['items'] as List),
      checkedIndices: map['checkedIndices'] != null
          ? Set<int>.from(map['checkedIndices'] as List)
          : {},
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      time: map['time'] as String?,
      event: map['event'] as String?,
      repeat: map['repeat'] as bool? ?? false,
      repeatDays: map['repeatDays'] != null
          ? List<int>.from(map['repeatDays'] as List)
          : [],
      isShared: map['isShared'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
