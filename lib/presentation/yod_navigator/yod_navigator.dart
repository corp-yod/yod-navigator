import 'package:flutter/material.dart';

enum YodNavigatorType {
  pushNamed,
  pushReplacementNamed,
  pushNamedAndRemoveUntil,
  pushNamedAndRemoveRemoveAll,
  pop,
  popUntil,
}

class YodNavigator extends NavigatorObserver {
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

  Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!context.mounted) {
      print('#->>> CoreNavigator().pushNamed(...) owner context not mounted');
      return null;
    }

    return _doPush(
      context,
      routeName,
      arguments: arguments,
      type: YodNavigatorType.pushNamed,
    );
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

    return _doPush(
      context,
      routeName,
      arguments: arguments,
      type: YodNavigatorType.pushReplacementNamed,
    );
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

    return _doPush(
      context,
      routeName,
      routePop: routePop,
      arguments: arguments,
      type: YodNavigatorType.pushNamedAndRemoveUntil,
    );
  }

  Future<dynamic> _doPush(
    BuildContext context,
    String routeName, {
    String? routePop,
    Object? arguments,
    required YodNavigatorType type,
  }) async {
    final route = Navigator.of(context);

    final routerMap = {
      YodNavigatorType.pushNamed: route.pushNamed(
        routeName,
        arguments: arguments,
      ),
      YodNavigatorType.pushReplacementNamed: route.pushReplacementNamed(
        routeName,
        arguments: arguments,
      ),
      YodNavigatorType.pushNamedAndRemoveUntil: route.pushNamedAndRemoveUntil(
        routeName,
        ModalRoute.withName(routePop ?? ''),
        arguments: arguments,
      ),
      YodNavigatorType.pushNamedAndRemoveRemoveAll: route
          .pushNamedAndRemoveUntil(routeName, (routePop) {
            if (routePop.isFirst == true) {
              return routePop.settings.name == '_mainRoute';
            }

            return false;
          }, arguments: arguments),
    };

    if (routerMap[type] == null) {
      return Future.value(null);
    }

    return routerMap[type];
  }
}
