import 'package:flutter/material.dart';
import '../features/onboarding/ui/pages/name_page.dart';

class AppRoutes {
  static const namePage = '/';

  static final routes = <String, WidgetBuilder>{
    namePage: (_) => const NamePage(),
  };
}
