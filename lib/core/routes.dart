import 'package:flutter/material.dart';
import '../features/auth/ui/pages/name_page.dart';

class AppRoutes {
  static const authEntry = '/';

  static final routes = <String, WidgetBuilder>{
    authEntry: (_) => const AuthEntryPage(),
  };
}
