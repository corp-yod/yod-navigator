import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class YodRouteBase {
  const YodRouteBase();
  RouteBase toRouteBase();
}

class YodRouterBase extends YodRouteBase {
  final String path;
  final String? name;
  final Widget Function(BuildContext, GoRouterState) builder;
  Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder;
  GlobalKey<NavigatorState>? parentNavigatorKey;
  FutureOr<String?> Function(BuildContext, GoRouterState)? redirect;
  FutureOr<bool> Function(BuildContext, GoRouterState)? onExit;
  bool caseSensitive = true;
  final List<YodRouteBase> routes;

  YodRouterBase({
    required this.path,
    this.name,
    required this.builder,
    this.pageBuilder,
    this.parentNavigatorKey,
    this.redirect,
    this.onExit,
    this.caseSensitive = true,
    this.routes = const [],
  });

  @override
  GoRoute toRouteBase() => GoRoute(
    path: path,
    name: name,
    builder: builder,
    pageBuilder: pageBuilder,
    parentNavigatorKey: parentNavigatorKey,
    redirect: redirect,
    onExit: onExit,
    caseSensitive: caseSensitive,
    routes: routes.map((r) => r.toRouteBase()).toList(),
  );
}
