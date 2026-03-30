import 'package:flutter/material.dart';

abstract class YodRouterGenerator {
  void init() {}
  Set<String> routes();
  Route<dynamic>? onGenerateRoute(RouteSettings settings);
}
