import 'package:flutter/cupertino.dart';

import '../../../flutter_modular.dart';
import '../modular_base.dart';
import 'modular_page.dart';

class ModularBook {
  final List<ParallelRoute> routes;
  Uri get uri => routes.isEmpty ? Uri.parse('/') : routes.last.uri;

  const ModularBook({required this.routes});

  Iterable<ModularPage> chapters([String chapter = '']) {
    final filteredRoutes =
        routes.where((route) => route.schema == chapter).toList();
    final pages = <ModularPage>[];
    for (var i = 0; i < filteredRoutes.length; i++) {
      final route = filteredRoutes[i];
      pages.add(ModularPage(
        key: ValueKey('${route.uri}@${route.schema}@$i'),
        route: route,
        // [chapters] runs on every rebuild, so `Modular.args` here is the
        // args of whichever route was matched last -- correct only for the
        // top page. Prefer the args captured when the route was pushed.
        args: route.bindedArgs ?? Modular.args,
        flags: (Modular as ModularBase).flags,
      ));
    }

    return pages;
  }

  ModularBook copyWith({
    List<ParallelRoute>? routes,
    Uri? uri,
  }) {
    return ModularBook(
      routes: routes ?? this.routes,
    );
  }
}
