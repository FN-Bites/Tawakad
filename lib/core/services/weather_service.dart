import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  WeatherService._();
  static final instance = WeatherService._();

// Makkah fallback if location is unavailable
  static const double _fallbackLat = 21.3891;
  static const double _fallbackLon = 39.8579;

  Future<String> getWeatherForDate(DateTime date) async {
    try {
      final position = await _getLocation();
      final lat = position?.latitude ?? _fallbackLat;
      final lon = position?.longitude ?? _fallbackLon;

      final dateStr = _formatDate(date);

      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lon'
        '&daily=weathercode,temperature_2m_max'
        '&timezone=auto'
        '&start_date=$dateStr'
        '&end_date=$dateStr',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return 'sunny';

      final data = jsonDecode(response.body);
      final codes = List<int>.from(data['daily']['weathercode']);
      final temps = List<double>.from(
        (data['daily']['temperature_2m_max'] as List)
            .map((e) => (e as num).toDouble()),
      );

      if (codes.isEmpty) return 'sunny';
      return _classify(codes.first, temps.first);
    } catch (_) {
      return 'sunny';
    }
  }

  Future<Position?> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  String _classify(int code, double maxTemp) {
    if (code >= 51 && code <= 99) return 'rainy';
    if (code <= 3) return maxTemp > 32 ? 'sunny' : 'warm';
    if (code >= 40 && code <= 49) return 'warm';
    return 'sunny';
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
