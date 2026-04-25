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

  Map<String, TabcontrollerInterface>? _appTabControllerMap = {};

  final String _mainRoute = '/main';
  final String mainAppTravelToGether = '/mainAppTravelToGether';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('#->>> didPush ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('#->>> didPop ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('#->>> didRemove ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print(
      '#->>> didReplace ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    print(
      '#->>> didChangeTop ${previousTopRoute?.settings.name} -> ${topRoute.settings.name}',
    );
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    print('#->>> didStartUserGesture ${route.settings.name}');
  }

  @override
  void didStopUserGesture() {
    print('#->>> didStopUserGesture');
  }

  void registerTabController(
    TabcontrollerInterface appTabController, {
    required CONTROLLERAPP controllerApp,
  }) {
    _appTabControllerMap?[controllerApp.name] = appTabController;
  }

  Future<dynamic> tabAnimateTo(
    BuildContext context,
    NavBarName tabName, {
    Map<String, dynamic>? arguments,
    CONTROLLERAPP? controllerApp = CONTROLLERAPP.MAINAPP,
    bool reload = false,
  }) async {
    print(
      '#->>> tabAnimateTo appTabControllerMap ${_appTabControllerMap?[controllerApp?.name]?.getTabcontroller.length}, $controllerApp -> $tabName',
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

    _appTabControllerMap?[controllerApp?.name]?.animateTo(
      tabName,
      context,
      reload: reload,
    );
    return null;
  }

  Future<Map<String, dynamic>?> getArguments(BuildContext context) async {
    GoRouterState state = GoRouterState.of(context);
    final result = await Future.microtask(
      () => state.extra as Map<String, dynamic>?,
    );

    return result;
  }

  Future<dynamic> push(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> CoreNavigator().pushNamed(...) owner context not mounted');
      return null;
    }

    return _doPush(context, routeName, arguments: arguments);
  }

  Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> CoreNavigator().pushNamed(...) owner context not mounted');
      return null;
    }

    return _doPushNamed(context, routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> CoreNavigator().pushReplacementNamed(...) owner context not mounted',
      );
      return null;
    }

    return _doPushReplacementNamed(context, routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName,
    String routePop, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> CoreNavigator().pushAndRemoveUntil(...) owner context not mounted',
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

  Future<dynamic> go(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> CoreNavigator().pushAndRemoveUntil(...) owner context not mounted',
      );
      return null;
    }

    return _doGo(context, routeName, arguments: arguments);
  }

  Future<dynamic> goNamed(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print(
        '#->>> CoreNavigator().pushAndRemoveUntil(...) owner context not mounted',
      );
      return null;
    }

    return _doGoNamed(context, routeName, arguments: arguments);
  }

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
    Object? arguments,
  }) {
    // return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    return context.pushNamed(routeName, extra: arguments);
  }

  void _doPushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // return Navigator.of(
    //   context,
    // ).pushReplacementNamed(routeName, arguments: arguments);
    return context.pushReplacement(routeName, extra: arguments);
  }

  void _doPushNamedAndRemoveUntil(
    BuildContext context,
    String routeName,
    String routePop, {
    Object? arguments,
  }) {
    // return Navigator.of(context).pushNamedAndRemoveUntil(
    //   routeName,
    //   ModalRoute.withName(routePop),
    //   arguments: arguments,
    // );
    return context.pushReplacementNamed(routeName, extra: arguments);
  }

  void _doGo(BuildContext context, String routeName, {Object? arguments}) {
    return context.go(routeName, extra: arguments);
  }

  void _doGoNamed(BuildContext context, String routeName, {Object? arguments}) {
    return context.goNamed(routeName, extra: arguments);
  }

  void _doPopUntil<T extends Object?>(
    BuildContext context,
    String routeName, [
    T? arguments,
  ]) {
    final router = GoRouter.of(context);
    final matchedLocation =
        router.routerDelegate.currentConfiguration.matches.last.matchedLocation;

    while (matchedLocation != routeName) {
      if (!context.canPop()) {
        return;
      }
      context.pop(arguments);
    }
  }
}
