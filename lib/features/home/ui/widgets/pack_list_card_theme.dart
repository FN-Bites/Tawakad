import 'package:flutter/material.dart';

//Tempoary file
class PackListCardTheme {
  const PackListCardTheme({
    required this.gradient,
    required this.shadowColor,
  });

  final LinearGradient gradient;
  final Color shadowColor;

  static const purple = PackListCardTheme(
    gradient: LinearGradient(
      colors: [Color(0xFFB57BEE), Color(0xFF9B59D8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0xFF9B59D8),
  );

  static const blue = PackListCardTheme(
    gradient: LinearGradient(
      colors: [Color(0xFF5B9EF0), Color(0xFF2F7DD4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0xFF2F7DD4),
  );

  static const green = PackListCardTheme(
    gradient: LinearGradient(
      colors: [Color(0xFF5DD48D), Color(0xFF2BAF65)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0xFF2BAF65),
  );

  static const pink = PackListCardTheme(
    gradient: LinearGradient(
      colors: [Color(0xFFF07EB0), Color(0xFFD84F8A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0xFFD84F8A),
  );

  static const orange = PackListCardTheme(
    gradient: LinearGradient(
      colors: [Color(0xFFFFAA5B), Color(0xFFE07820)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shadowColor: Color(0xFFE07820),
  );

  static const List<PackListCardTheme> all = [
    purple,
    blue,
    green,
    pink,
    orange,
  ];
}
