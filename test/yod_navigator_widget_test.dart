import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yod_navigator/presentation/yod_navigator/yod_navigator.dart';
import 'package:yod_navigator/src/common_interface/tabcontroller/tabcontroller_interface.dart';

class _TestTabcontrollerInterface extends TabcontrollerInterface {
  _TestTabcontrollerInterface({required this.indexMap});

  final Map<NavBarName, int> indexMap;

  @override
  int getIndex(NavBarName navBarName) => indexMap[navBarName] ?? -1;
}

class _RouteScreen extends StatelessWidget {
  const _RouteScreen({required this.label, required this.onBuild});

  final String label;
  final ValueChanged<BuildContext> onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return Scaffold(body: Text(label));
  }
}

void main() {
  group('YodNavigator widget integration', () {
    late YodNavigator navigator;
    late BuildContext mainContext;
    late BuildContext detailsContext;
    late BuildContext profileContext;
    late BuildContext subDetailsContext;
    late BuildContext travelContext;
    late GoRouter router;

    Future<void> pumpRouterApp(WidgetTester tester) async {
      router = GoRouter(
        initialLocation: '/main',
        routes: [
          GoRoute(
            path: '/main',
            name: 'main',
            builder: (context, state) => _RouteScreen(
              label: 'main',
              onBuild: (value) => mainContext = value,
            ),
          ),
          GoRoute(
            path: '/details',
            name: 'details',
            builder: (context, state) => _RouteScreen(
              label: 'details',
              onBuild: (value) => detailsContext = value,
            ),
            routes: [
              GoRoute(
                path: 'sub',
                name: 'details-sub',
                builder: (context, state) => _RouteScreen(
                  label: 'details-sub',
                  onBuild: (value) => subDetailsContext = value,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile/:id',
            name: 'profile',
            builder: (context, state) => _RouteScreen(
              label: 'profile-${state.pathParameters['id']}',
              onBuild: (value) => profileContext = value,
            ),
          ),
          GoRoute(
            path: '/mainAppTravelToGether',
            name: 'travel',
            builder: (context, state) => _RouteScreen(
              label: 'travel',
              onBuild: (value) => travelContext = value,
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
    }

    setUp(() {
      navigator = YodNavigator();
    });

    testWidgets('push navigates and exposes route arguments', (tester) async {
      await pumpRouterApp(tester);

      unawaited(
        navigator.push(
          mainContext,
          '/details',
          arguments: const {'source': 'main'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('details'), findsOneWidget);
      expect(
        await navigator.getArguments(detailsContext),
        equals(const {'source': 'main'}),
      );
    });

    testWidgets('pushNamed navigates with path parameters', (tester) async {
      await pumpRouterApp(tester);

      unawaited(
        navigator.pushNamed(
          mainContext,
          'profile',
          pathParameters: const {'id': '7'},
          queryParameters: const {'tab': 'info'},
          arguments: const {'source': 'pushNamed'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('profile-7'), findsOneWidget);
      expect(
        await navigator.getPathParameters(profileContext),
        equals(const {'id': '7'}),
      );
      expect(
        await navigator.getArguments(profileContext),
        equals(const {'source': 'pushNamed'}),
      );
    });

    testWidgets('go and goNamed replace the current location', (tester) async {
      await pumpRouterApp(tester);

      await navigator.go(mainContext, '/details', arguments: const {'from': 'go'});
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
      expect(
        await navigator.getArguments(detailsContext),
        equals(const {'from': 'go'}),
      );

      await navigator.goNamed(
        detailsContext,
        'profile',
        pathParameters: const {'id': '42'},
        arguments: const {'from': 'goNamed'},
        fragment: 'section-a',
      );
      await tester.pumpAndSettle();

      expect(find.text('profile-42'), findsOneWidget);
      expect(
        await navigator.getPathParameters(profileContext),
        equals(const {'id': '42'}),
      );
      expect(
        await navigator.getArguments(profileContext),
        equals(const {'from': 'goNamed'}),
      );
    });

    testWidgets('pushReplacement replaces the top route', (tester) async {
      await pumpRouterApp(tester);

      unawaited(navigator.push(mainContext, '/details'));
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);

      unawaited(
        navigator.pushReplacement(
          detailsContext,
          '/profile/9',
          arguments: const {'source': 'replacement'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('profile-9'), findsOneWidget);
      expect(
        await navigator.getArguments(profileContext),
        equals(const {'source': 'replacement'}),
      );
    });

    testWidgets('pop returns to the previous route', (tester) async {
      await pumpRouterApp(tester);

      unawaited(navigator.push(mainContext, '/details'));
      await tester.pumpAndSettle();

      navigator.pop(detailsContext);
      await tester.pumpAndSettle();

      expect(find.text('main'), findsOneWidget);
    });

    testWidgets('popUntil stops at the requested route', (tester) async {
      await pumpRouterApp(tester);

      unawaited(navigator.push(mainContext, '/details'));
      await tester.pumpAndSettle();
      unawaited(navigator.push(detailsContext, '/details/sub'));
      await tester.pumpAndSettle();

      navigator.popUntil(subDetailsContext, '/details');
      await tester.pumpAndSettle();

      expect(find.text('details'), findsOneWidget);
      expect(find.text('details-sub'), findsNothing);
    });

    testWidgets('pushNamedAndRemoveUntil currently behaves as a no-op', (
      tester,
    ) async {
      await pumpRouterApp(tester);

      await navigator.pushNamedAndRemoveUntil(
        mainContext,
        'profile',
        '/main',
        arguments: const {'ignored': true},
      );
      await tester.pumpAndSettle();

      expect(find.text('main'), findsOneWidget);
    });

    testWidgets('tabAnimateTo updates the registered main app controller', (
      tester,
    ) async {
      await pumpRouterApp(tester);

      final controller = _TestTabcontrollerInterface(
        indexMap: const {
          NavBarName.HOME: 0,
          NavBarName.SEARCH: 1,
          NavBarName.PROFILE: 2,
        },
      )..initTabController(length: 3);

      navigator.registerTabController(
        controller,
        controllerApp: CONTROLLERAPP.MAINAPP,
      );

      await navigator.tabAnimateTo(mainContext, NavBarName.PROFILE);

      expect(controller.getCurrent(), 2);

      controller.dispose();
    });

    testWidgets('tabAnimateTo updates the registered travel app controller', (
      tester,
    ) async {
      await pumpRouterApp(tester);

      await navigator.go(mainContext, '/mainAppTravelToGether');
      await tester.pumpAndSettle();

      final controller = _TestTabcontrollerInterface(
        indexMap: const {
          NavBarName.HOME: 0,
          NavBarName.SEARCH: 1,
          NavBarName.PROFILE: 2,
        },
      )..initTabController(length: 3);

      navigator.registerTabController(
        controller,
        controllerApp: CONTROLLERAPP.TRAVELAPP,
      );

      await navigator.tabAnimateTo(
        travelContext,
        NavBarName.SEARCH,
        controllerApp: CONTROLLERAPP.TRAVELAPP,
      );

      expect(controller.getCurrent(), 1);

      controller.dispose();
    });

    testWidgets('mounted navigation context is reflected in router state', (
      tester,
    ) async {
      await pumpRouterApp(tester);

      expect(router.state.path, '/main');
      expect(mainContext.mounted, isTrue);
    });
  });
}