import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart' show Modular;
import 'package:flutter_modular/src/flutter_modular_module.dart' show injector;
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/models/modular_args.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

import '../modular_base_test.dart';

class BuildContextMock extends Mock implements BuildContext {}

class AnimationMock<T> extends Mock implements Animation<T> {}

void main() {
  test('ModularPage.empty', () {
    final page = ModularPage.empty();
    expect(page.name, '/');
  });

  test('createRoute throw error child null', () {
    final page = ModularPage.empty();
    expect(() => page.createRoute(BuildContextMock()),
        throwsA(isA<ModularPageException>()));
  });

  test('createRoute default route', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    when(() => route.child).thenReturn((_) => Container());
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);
    when(() => route.isFullscreenDialog).thenReturn(true);
    when(() => route.transition).thenReturn(TransitionType.defaultTransition);
    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    expect(page.createRoute(context), isA<Route>());
  });

  test('createRoute default route cupertino', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_) => widget);
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.isFullscreenDialog).thenReturn(true);
    when(() => route.maintainState).thenReturn(true);

    when(() => route.transition).thenReturn(TransitionType.defaultTransition);
    final page = ModularPage(
      args: args,
      flags: ModularFlags(isCupertino: true),
      route: route,
    );
    final routePage = page.createRoute(context);
    expect(routePage, isA<CupertinoPageRoute>());
    expect((routePage as CupertinoPageRoute).builder(context), widget);
  });

  test('createRoute noTransition', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_) => widget);
    when(() => route.maintainState).thenReturn(true);
    when(() => route.isFullscreenDialog).thenReturn(true);
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.transition).thenReturn(TransitionType.noTransition);
    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    final pageRoute = page.createRoute(context);
    expect(pageRoute, isA<NoTransitionMaterialPageRoute>());
    expect(
      (pageRoute as NoTransitionMaterialPageRoute).builder(context),
      widget,
    );
    expect(pageRoute.transitionDuration, Duration.zero);
    expect(
      pageRoute.buildTransitions(
        context,
        AnimationMock<double>(),
        AnimationMock<double>(),
        widget,
      ),
      widget,
    );

    final pageRouteGenerate = page.createRoute(context);
    expect(pageRouteGenerate, isA<Route>());
  });

  test('createRoute custom', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_) => widget);
    when(() => route.isFullscreenDialog).thenReturn(true);
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);

    when(() => route.transition).thenReturn(TransitionType.custom);
    when(() => route.customTransition).thenReturn(
        CustomTransition(transitionBuilder: (_, __, ___, child) => child));

    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    final pageRoute = page.createRoute(context);
    expect(pageRoute, isA<PageRouteBuilder>());
    expect(
        (pageRoute as PageRouteBuilder).pageBuilder(
            context, AnimationMock<double>(), AnimationMock<double>()),
        widget);
  });

  test('createRoute other transitions', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();

    final transitionMap = ParallelRoute.empty().transitions;
    final anim = AnimationMock<double>();
    when(() => anim.status).thenReturn(AnimationStatus.completed);
    final keys = transitionMap.keys
        .where((k) => k != TransitionType.custom)
        .where((k) => k != TransitionType.defaultTransition)
        .where((k) => k != TransitionType.noTransition)
        .toList();

    for (final key in keys) {
      when(() => route.transition).thenReturn(key);
      when(() => route.transitions).thenReturn(transitionMap);
      when(() => route.child).thenReturn((_) => widget);
      when(() => route.maintainState).thenReturn(true);

      when(() => route.uri).thenReturn(Uri.parse('/'));
      when(() => route.duration).thenReturn(Duration.zero);

      final page = ModularPage(args: args, flags: ModularFlags(), route: route);
      final pageRoute = page.createRoute(context);
      expect(pageRoute, isA<PageRouteBuilder>());

      if (key == TransitionType.fadeIn) {
        expect((pageRoute as PageRouteBuilder).pageBuilder(context, anim, anim),
            widget);
        expect(
            pageRoute.buildTransitions(context, AnimationMock<double>(),
                AnimationMock<double>(), widget),
            isA<FadeTransition>());
      } else {
        expect((pageRoute as PageRouteBuilder).pageBuilder(context, anim, anim),
            widget);
        expect(pageRoute.buildTransitions(context, anim, anim, widget),
            isA<Widget>());
      }

      reset(route);
    }
  });

  test('createRoute full screen dialog route', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    when(() => route.child).thenReturn((_) => Container());
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);
    when(() => route.isFullscreenDialog).thenReturn(true);
    when(() => route.transition).thenReturn(TransitionType.defaultTransition);
    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    expect(page.createRoute(context), isA<Route>());
    expect(page.route.isFullscreenDialog, equals(true));
  });

  test('createRoute builds the child with the args of its own page', () {
    // NavigatorState.restoreState rebuilds every page of the stack in one
    // synchronous loop, long after navigation moved Modular.args on to
    // another route. A builder that reads Modular.args must still see the
    // args of the route it belongs to -- otherwise a page lower in the
    // stack is handed the top route's payload and casts it to the wrong
    // type, or renders the wrong record.
    final tracker = injector.get<Tracker>();
    final ownArgs = ModularArguments(
      uri: Uri.parse('/orders/'),
      data: {'useDefaultLeading': true},
      params: const {'id': '1'},
    );
    final topOfStackArgs = ModularArguments(
      uri: Uri.parse('/orders/2'),
      data: 'payload that belongs to another route',
      params: const {'id': '2'},
    );
    tracker.setArguments(topOfStackArgs);

    ModularArguments? seenByBuilder;
    final route = ParallelRouteMock();
    when(() => route.child).thenReturn((_) {
      seenByBuilder = Modular.args;
      return Container();
    });
    when(() => route.uri).thenReturn(Uri.parse('/orders/'));
    when(() => route.maintainState).thenReturn(true);
    when(() => route.isFullscreenDialog).thenReturn(false);
    when(() => route.transition).thenReturn(TransitionType.defaultTransition);

    ModularPage(args: ownArgs, flags: ModularFlags(), route: route)
        .createRoute(BuildContextMock());

    expect(seenByBuilder?.data, {'useDefaultLeading': true});
    expect(seenByBuilder?.params['id'], '1');

    // and the global is handed back to whoever actually owns it
    expect(tracker.arguments, same(topOfStackArgs));
  });
}
