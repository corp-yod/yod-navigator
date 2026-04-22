import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return _go(context, routeName, arguments: arguments);
  }

  Future<dynamic> _doPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    return context.push(routeName, extra: arguments);
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

  void _go(BuildContext context, String routeName, {Object? arguments}) {
    // return Navigator.of(context).pushNamedAndRemoveUntil(routeName, (routePop) {
    //   if (routePop.isFirst == true) {
    //     return routePop.settings.name == '_mainRoute';
    //   }

    //   return false;
    // }, arguments: arguments);
    return context.go(routeName, extra: arguments);
  }
}
