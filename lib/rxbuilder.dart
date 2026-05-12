import 'package:flutter/widgets.dart';

import 'rx.dart';

class Rxb extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const Rxb(this.builder, {super.key});

  @override
  State<Rxb> createState() => _RxbState();
}

class _RxbState extends State<Rxb> {
  final Set<Listenable> _deps = <Listenable>{};

  void _onDependencyChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final dep in _deps) {
      dep.removeListener(_onDependencyChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextDeps = <Listenable>{};

    final child = RxTracker.track(
      (listenable) {
        nextDeps.add(listenable);
      },
      () {
        return widget.builder(context);
      },
    );

    for (final dep in _deps.difference(nextDeps)) {
      dep.removeListener(_onDependencyChanged);
    }

    for (final dep in nextDeps.difference(_deps)) {
      dep.addListener(_onDependencyChanged);
    }

    _deps
      ..clear()
      ..addAll(nextDeps);

    return child;
  }
}
