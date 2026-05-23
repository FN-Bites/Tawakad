import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//To run
//1- open terminal
//Write - cd toki_backend
// paste - uvicorn app:app --reload --host 0.0.0.0 --port 8000

class LocationResult {
  final String? canonical;
  final bool matched;
  final List<String> events;
  final Map<String, String> eventsArabic;

  const LocationResult({
    required this.canonical,
    required this.matched,
    required this.events,
    this.eventsArabic = const {},
  });

  factory LocationResult.empty() => const LocationResult(
        canonical: null,
        matched: false,
        events: [],
        eventsArabic: {},
      );
}

class RecommendedItem {
  final String arabic;
  final String english;
  final double score;

  const RecommendedItem({
    required this.arabic,
    required this.english,
    required this.score,
  });
}

class RecommendationService {
  static const String _base = 'http://192.168.8.165:8000';

  RecommendationService._();
  static final RecommendationService instance = RecommendationService._();

  final http.Client _client = http.Client();

  Future<LocationResult> normalizeLocation(String listName) async {
    final cleanListName = listName.trim();

    if (cleanListName.isEmpty) {
      return LocationResult.empty();
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$_base/normalize_location'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'list_name': cleanListName}),
          )
          .timeout(const Duration(seconds: 6));

      debugPrint('normalizeLocation status: ${response.statusCode}');
      debugPrint('normalizeLocation body: ${response.body}');

      if (response.statusCode != 200) return LocationResult.empty();

      final Map<String, dynamic> body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final eventsLocalized = body['events_localized'] as List? ?? [];
      final eventsArabic = <String, String>{
        for (final e in eventsLocalized)
          (e['english'] as String): (e['arabic'] as String),
      };

      return LocationResult(
        canonical: body['canonical'] as String?,
        matched: body['matched'] as bool? ?? false,
        events: List<String>.from(body['events'] as List? ?? []),
        eventsArabic: eventsArabic,
      );
    } catch (e) {
      debugPrint('RecommendationService.normalizeLocation error: $e');
      return LocationResult.empty();
    }
  }

  Future<List<RecommendedItem>> getRecommendations({
    required String listName,
    required String event,
    required String period,
    required String weather,
    required String gender,
    required String role,
    int topN = 15,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_base/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'list_name': listName.trim(),
              'event': event.trim(),
              'period': period.trim(),
              'weather': weather.trim(),
              'gender': gender.trim(),
              'role': role.trim(),
              'top_n': topN,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('getRecommendations status: ${response.statusCode}');
      debugPrint('getRecommendations body: ${response.body}');

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final arabicItems =
          List<String>.from(body['arabic_items'] as List? ?? []);
      final englishItems =
          List<String>.from(body['english_items'] as List? ?? []);
      final scores = List<double>.from(
        (body['scores'] as List? ?? []).map((s) => (s as num).toDouble()),
      );

      final count = arabicItems.length;

      return List.generate(count, (i) {
        return RecommendedItem(
          arabic: arabicItems[i],
          english: i < englishItems.length ? englishItems[i] : '',
          score: i < scores.length ? scores[i] : 0.0,
        );
      });
    } catch (e) {
      debugPrint('RecommendationService.getRecommendations error: $e');
      return [];
    }
  }
}
