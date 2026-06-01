import 'package:flutter_test/flutter_test.dart';
import 'package:tawakad_app/core/services/recommendation_service.dart';

void main() {
  
  group('RecommendationService Integration Tests', () {
    test(
      'normalizeLocation returns a valid response for a known location',
      () async {
        final result = await RecommendationService.instance.normalizeLocation(
          'gym',
        );

        expect(result.matched, true);
        expect(result.events, isA<List<String>>());
        expect(result.events, contains('Boxing'));
      },
    );

    test(
      'getRecommendations returns a recommendation list',
      () async {
        final result = await RecommendationService.instance.getRecommendations(
          listName: 'Gym',
          event: 'Boxing',
          period: 'Afternoon',
          weather: 'Sunny',
          gender: 'Male',
          role: 'Gym User',
        );

        expect(result, isNotEmpty);
        expect(result.first.arabic, isNotEmpty);
        expect(result.first.english, isNotEmpty);
        expect(result.first.score, greaterThan(0));
      },
    );
  });
}
