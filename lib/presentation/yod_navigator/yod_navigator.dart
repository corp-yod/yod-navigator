import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yod_navigator/src/common_interface/tabcontroller/tabcontroller_interface.dart';

enum NavBarName { HOME, SEARCH, PROFILE, CURRENT }

enum CONTROLLERAPP { MAINAPP, TRAVELAPP }

class YodNavigator extends NavigatorObserver {
  factory YodNavigator() {
    return _instance;
  }

  YodNavigator._();
  static final YodNavigator _instance = YodNavigator._();

  final Map<String, TabcontrollerInterface> _appTabControllerMap = {};
  final List<RouteHistory> _routeHistory = [];

  final String _mainRoute = '/main';
  final String mainAppTravelToGether = '/mainAppTravelToGether';

  @visibleForTesting
  List<RouteHistory> get routeHistory => List.unmodifiable(_routeHistory);

  @visibleForTesting
  void clearRouteHistory() {
    _routeHistory.clear();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.add(RouteHistory(routeName: route.settings.name.toString()));

    if (kDebugMode) {
      final List<String> routeNames = _routeHistory
          .map((route) => route.routeName)
          .toList();
      print('YodNavigator didPush: $routeNames');
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (_routeHistory.isNotEmpty) {
      _routeHistory.removeLast();
    }

    _routeHistory.add(
      RouteHistory(routeName: newRoute!.settings.name.toString()),
    );

    if (kDebugMode) {
      final List<String> routeNames = _routeHistory
          .map((route) => route.routeName)
          .toList();
      print('YodNavigator didReplace: $routeNames');
    }

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.removeLast();

    if (kDebugMode) {
      final List<String> routeNames = _routeHistory
          .map((route) => route.routeName)
          .toList();
      print('YodNavigator didPop: $routeNames');
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.remove(
      RouteHistory(routeName: route.settings.name.toString()),
    );

    if (kDebugMode) {
      final List<String> routeNames = _routeHistory
          .map((route) => route.routeName)
          .toList();
      print('YodNavigator didRemove: $routeNames');
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    print(
      'YodNavigator didChangeTop: ${previousTopRoute?.settings.name} -> ${topRoute.settings.name}',
    );
    super.didChangeTop(topRoute, previousTopRoute);
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    print('YodNavigator didStartUserGesture: ${route.settings.name}');
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    print('YodNavigator didStopUserGesture');
    super.didStopUserGesture();
  }

  // Method to register TabController for each app
  void registerTabController(
    TabcontrollerInterface appTabController, {
    required CONTROLLERAPP controllerApp,
  }) {
    _appTabControllerMap[controllerApp.name] = appTabController;
  }

  // Method to animate to a specific tab in the registered TabController
  Future<dynamic> tabAnimateTo(
    BuildContext context,
    NavBarName tabName, {
    Map<String, dynamic>? arguments,
    CONTROLLERAPP? controllerApp = CONTROLLERAPP.MAINAPP,
    bool reload = false,
  }) async {
    print(
      '#->>> tabAnimateTo appTabControllerMap ${_appTabControllerMap[controllerApp?.name]?.getTabcontroller.length}, $controllerApp -> $tabName',
    );

    switch (controllerApp) {
      case CONTROLLERAPP.MAINAPP:
        _doPopUntil(context, _mainRoute);

        break;
      case CONTROLLERAPP.TRAVELAPP:
        _doPopUntil(context, mainAppTravelToGether);

        break;
      default:
    }

    _appTabControllerMap[controllerApp?.name]?.animateTo(
      tabName,
      context,
      reload: reload,
    );
    return null;
  }

  // Method to get arguments from the current route
  Future<Map<String, dynamic>?> getArguments(BuildContext context) async {
    GoRouterState state = GoRouterState.of(context);
    final result = await Future.microtask(
      () => state.extra as Map<String, dynamic>?,
    );

    return result;
  }

  // Method to get path parameters from the current route
  Future<Map<String, dynamic>?> getPathParameters(BuildContext context) async {
    GoRouterState state = GoRouterState.of(context);
    final result = await Future.microtask(
      () => state.pathParameters as Map<String, dynamic>?,
    );

    return result;
  }

  // |----------------------------------------------------------------------------------------------|
  // |------------------ Public Methods for Navigation Actions (Using go_router) -------------------|
  // |----------------------------------------------------------------------------------------------|

  Future<dynamic> push(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> YodNavigator().push(...) owner context not mounted');
      return null;
    }

    return _doPush(context, routeName, arguments: arguments);
  }

  Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> YodNavigator().pushNamed(...) owner context not mounted');
      return null;
    }

    return _doPushNamed(
      context,
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      arguments: arguments,
    );
  }

  Future<dynamic> go(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> YodNavigator().go(...) owner context not mounted');
      return null;
    }

    return _doGo(context, routeName, arguments: arguments);
  }

  Future<dynamic> goNamed(
    BuildContext context,
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Map<String, dynamic>? arguments,
    String? fragment,
  }) async {
    if (!context.mounted) {
      print('#->>> YodNavigator().goNamed(...) owner context not mounted');
      return null;
    }

    return _doGoNamed(
      context,
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      arguments: arguments,
      fragment: fragment,
    );
  }

  Future<dynamic> pushReplacement(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> YodNavigator().pushReplacement(...) owner context not mounted',
      );
      return null;
    }

    return _doPushReplacement(context, routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName,
    String routePop, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> YodNavigator().pushAndRemoveUntil(...) owner context not mounted',
      );
      return null;
    }

    return _doPushNamedAndRemoveUntil(
      context,
      routeName,
      routePop,
      arguments: arguments,
    );
  }

  pop(BuildContext context, {Map<String, dynamic>? arguments}) {
    _doPop(context, arguments);
  }

  popUntil(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    _doPopUntil(context, routeName, arguments);
  }

  // |----------------------------------------------------------------------------------------------|
  // |------------------ Private Methods for Navigation Actions (Using go_router) ------------------|
  // |----------------------------------------------------------------------------------------------|

  Future<dynamic> _doPush(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    return context.push(routeName, extra: arguments);
  }

  Future<dynamic> _doPushNamed(
    BuildContext context,
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? arguments,
  }) {
    return context.pushNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: arguments,
    );
  }

  void _doGo(BuildContext context, String routeName, {Object? arguments}) {
    return context.go(routeName, extra: arguments);
  }

  void _doGoNamed(
    BuildContext context,
    String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? arguments,
    String? fragment,
  }) {
    return context.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: arguments,
      fragment: fragment,
    );
  }

  void _doPushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return context.pushReplacement(routeName, extra: arguments);
  }

  //TODO pushNamedAndRemoveUntil ยังไม่รองรับต้องแก้ไขให้รองรับในอนาคต
  void _doPushNamedAndRemoveUntil(
    BuildContext context,
    String routeName,
    String routePop, {
    Object? arguments,
  }) {
    // return context.pushReplacementNamed(routeName, extra: arguments);
  }

  void _doPop<T extends Object?>(BuildContext context, [T? arguments]) {
    return context.pop(arguments);
  }

  void _doPopUntil<T extends Object?>(
    BuildContext context,
    String routeName, [
    T? arguments,
  ]) {
    final router = GoRouter.of(context);
    while (router
            .routerDelegate
            .currentConfiguration
            .matches
            .last
            .matchedLocation !=
        routeName) {
      if (!context.canPop()) {
        return;
      }
      context.pop(arguments);
    }
  }

  // -----------------------------------------------------------------------------------------------|
  // |------------------ Private Methods for Navigation Actions (Using go_router) ------------------|
  // -----------------------------------------------------------------------------------------------|
}

class RouteHistory {
  RouteHistory({required this.routeName});

  String routeName;

  @override
  bool operator ==(Object other) {
    return other is RouteHistory && routeName == other.routeName;
  }

  // @override
  // int get hashCode => routeName.hashCode;
}
