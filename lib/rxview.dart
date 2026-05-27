import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'rx_lifecycle.dart';

/// Página/widget base que resolve o controller automaticamente via [GetIt],
/// dispensando declarar `final controller` e recebê-lo pelo construtor.
///
/// Inspirado no `GetView<T>` do GetX, porém usando o `get_it` que já é o
/// service locator deste projeto.
///
/// Ao montar a tela, chama [RxLifeCycleMixin.onStart] no controller quando
/// ele usa [RxController] (ou o mixin diretamente).
///
/// Uso:
/// ```dart
/// class DiscoverPage extends RxView<DiscoverController> {
///   const DiscoverPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Text(controller.someValue);
///   }
/// }
/// ```
///
/// O controller deve estar previamente registrado no `GetIt` (geralmente em
/// um arquivo de `bindings`). Para registrar mais de uma instância do mesmo
/// tipo, sobrescreva [instanceName] na sua página.
abstract class RxView<T extends Object> extends StatefulWidget {
  const RxView({super.key});

  /// Nome opcional da instância registrada no [GetIt] para resolver registros
  /// nomeados (equivalente à `tag` do GetX). Retorna `null` por padrão.
  String? get instanceName => null;

  /// Controller resolvido do [GetIt]. Lança erro caso o tipo [T] não esteja
  /// registrado, então garanta o registro nas suas `bindings`.
  T get controller => GetIt.instance.get<T>(instanceName: instanceName);

  /// Conteúdo da tela; mesma assinatura de antes, quando [RxView] era
  /// [StatelessWidget].
  Widget build(BuildContext context);

  @override
  State<RxView<T>> createState() => _RxViewState<T>();
}

class _RxViewState<T extends Object> extends State<RxView<T>> {
  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    if (c is RxLifeCycleMixin) {
      c.onStart();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}
