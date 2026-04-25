import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yod_navigator/presentation/yod_navigator/yod_navigator.dart';
import 'package:yod_navigator/src/common_interface/tabcontroller/tabcontroller_interface.dart';
import 'package:yod_navigator/yod_navigator.dart';

class _TestTabcontrollerInterface extends TabcontrollerInterface {
  _TestTabcontrollerInterface({required this.indexMap});

  final Map<NavBarName, int> indexMap;

  @override
  int getIndex(NavBarName navBarName) => indexMap[navBarName] ?? -1;
}

class _TestRouterModule extends YodRouterModule {
  _TestRouterModule(this._routes);

  final List<YodRouteBase> _routes;

  @override
  List<YodRouteBase> routes() => _routes;

  @override
  void init() {}
}

class _FakeGoRouterState implements GoRouterState {
  @override
  Uri get uri => Uri.parse('/');

  @override
  String get matchedLocation => '/';

  @override
  String? get name => null;

  @override
  String? get path => null;

  @override
  String? get fullPath => '/';

  @override
  Map<String, String> get pathParameters => const {};

  @override
  Object? get extra => null;

  @override
  GoException? get error => null;

  @override
  ValueKey<String> get pageKey => const ValueKey<String>('test');

  @override
  GoRoute? get topRoute => null;

  @override
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    String? fragment,
  }) {
    // TODO: implement namedLocation
    throw UnimplementedError();
  }
}

Route<void> _namedRoute(String name) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: name),
    builder: (_) => const SizedBox(),
  );
}

void main() {
  group('TabcontrollerInterface', () {
    test('initializes, animates and disposes a TabController', () {
      final host = _TestTabcontrollerInterface(
        indexMap: const {
          NavBarName.HOME: 0,
          NavBarName.SEARCH: 1,
          NavBarName.PROFILE: 2,
        },
      );

      host.initTabController(length: 3);

      expect(host.getTabcontroller.length, 3);
      expect(host.getCurrent(), 0);

      host.animateTo(NavBarName.PROFILE, null);

      expect(host.getCurrent(), 2);

      host.dispose();

      expect(host.getCurrent(), -1);
      expect(
        () => host.getTabcontroller,
        throwsA(
          isA<Exception>().having(
            (exception) => exception.toString(),
            'message',
            contains('TabController is null'),
          ),
        ),
      );
    });
  });

  group('YodRouterBase', () {
    test('converts itself and child routes to GoRoute', () {
      final router = YodRouterBase(
        path: '/parent',
        name: 'parent',
        builder: (_, __) => const SizedBox(),
        routes: [
          YodRouterBase(
            path: 'child',
            name: 'child',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      );

      final routeBase = router.toRouteBase();

      expect(routeBase, isA<GoRoute>());

      final goRoute = routeBase;

      expect(goRoute.path, '/parent');
      expect(goRoute.name, 'parent');
      expect(goRoute.routes, hasLength(1));
      expect(goRoute.routes.single, isA<GoRoute>());
      expect((goRoute.routes.single as GoRoute).path, 'child');
      expect((goRoute.routes.single as GoRoute).name, 'child');
    });
  });

  group('YodRouterModule', () {
    test('returns routes from subclass and defaults redirect to null', () {
      final routes = [
        YodRouterBase(
          path: '/home',
          name: 'home',
          builder: (_, __) => const SizedBox(),
        ),
      ];
      final module = _TestRouterModule(routes);

      expect(module.routes(), same(routes));
      expect(module.redirect(_FakeGoRouterState()), isNull);
    });
  });

  group('RouteHistory', () {
    test('compares route names for equality', () {
      expect(
        RouteHistory(routeName: '/main'),
        equals(RouteHistory(routeName: '/main')),
      );
      expect(
        RouteHistory(routeName: '/main'),
        isNot(equals(RouteHistory(routeName: '/profile'))),
      );
    });
  });

  test('YodNavigator factory returns the singleton instance', () {
    expect(YodNavigator(), same(YodNavigator()));
  });

  group('YodNavigator route history', () {
    late YodNavigator navigator;

    setUp(() {
      navigator = YodNavigator();
      navigator.clearRouteHistory();
    });

    test('observer callbacks keep route history in sync', () {
      final mainRoute = _namedRoute('/main');
      final detailsRoute = _namedRoute('/details');
      final profileRoute = _namedRoute('/profile');

      navigator.didPush(mainRoute, null);
      navigator.didPush(detailsRoute, mainRoute);

      expect(
        navigator.routeHistory.map((route) => route.routeName).toList(),
        equals(['/main', '/details']),
      );

      navigator.didReplace(newRoute: profileRoute, oldRoute: detailsRoute);

      expect(
        navigator.routeHistory.map((route) => route.routeName).toList(),
        equals(['/main', '/profile']),
      );

      navigator.didRemove(mainRoute, null);

      expect(
        navigator.routeHistory.map((route) => route.routeName).toList(),
        equals(['/profile']),
      );

      navigator.didPop(profileRoute, null);

      expect(navigator.routeHistory, isEmpty);
    });
  });
}
