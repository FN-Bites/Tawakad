import 'package:flutter_test/flutter_test.dart';
import 'package:tawakad_app/core/services/recommendation_service.dart';

void main() {
  group('RecommendationService Models', () {
    test('LocationResult.empty returns default values', () {
      // Arrange
      final result = LocationResult.empty();

      // Assert
      expect(result.canonical, null);
      expect(result.matched, false);
      expect(result.events, isEmpty);
      expect(result.eventsArabic, isEmpty);
    });

    test('RecommendedItem stores values correctly', () {
      // Arrange
      const item = RecommendedItem(
        arabic: 'مظلة',
        english: 'Umbrella',
        score: 0.95,
      );

      // Assert
      expect(item.arabic, 'مظلة');
      expect(item.english, 'Umbrella');
      expect(item.score, 0.95);
    });
  });
}