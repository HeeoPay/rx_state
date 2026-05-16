import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Ciclo de vida no estilo GetX ([onInit] síncrono, [onReady] após o primeiro
/// frame, [onClose] ao encerrar o controller).
///
/// Use com [RxController] ou aplique o mixin na sua classe registrada no
/// [GetIt]. Chame [onStart] uma vez quando o controller entrar em uso (por
/// exemplo ao montar a tela — [RxView] faz isso automaticamente).
mixin RxLifeCycleMixin {
  bool _initialized = false;
  bool _closed = false;

  /// Após [onStart] ter corrido com sucesso.
  bool get isInitialized => _initialized;

  /// Após [dispose] ou flag interna de encerramento.
  bool get isClosed => _closed;

  /// Primeira fase do ciclo (equivalente ao `onInit` do GetX).
  @protected
  void onInit() {}

  /// Disparado uma vez no frame seguinte a [onInit], quando a árvore já foi
  /// montada (equivalente ao `onReady` do GetX).
  @protected
  void onReady() {}

  /// Liberação de recursos (equivalente ao `onClose` do GetX). Só é chamado
  /// por [dispose].
  @mustCallSuper
  @protected
  void onClose() {}

  /// Inicia o ciclo: [onInit] e, em seguida, [onReady] agendado no pós-frame.
  /// É idempotente por instância (chamadas repetidas não fazem nada).
  ///
  /// **Singleton no GetIt:** normalmente só roda na primeira tela que usa o
  /// controller. **Factory / escopo de rota:** roda a cada nova instância.
  void onStart() {
    if (_initialized || _closed) {
      return;
    }
    _initialized = true;
    onInit();
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _callOnReadyIfStillOpen();
      });
    } else {
      SchedulerBinding.instance.endOfFrame.then((_) {
        _callOnReadyIfStillOpen();
      });
    }
  }

  void _callOnReadyIfStillOpen() {
    if (_closed) {
      return;
    }
    onReady();
  }

  /// Encerra o controller e chama [onClose] uma vez. Para controllers em
  /// escopo de rota, chame ao remover do [GetIt] ou ao sair da feature; em
  /// singletons costuma não ser chamado até o fim do app.
  @mustCallSuper
  void dispose() {
    if (_closed) {
      return;
    }
    _closed = true;
    onClose();
  }
}

/// Base opcional com o mesmo papel do `RxController` do GetX: somente mixin de
/// ciclo de vida, sem `update()` / `Obx` (no seu projeto a UI reage via
/// [RxValue] + [Rxb]).
abstract class RxController with RxLifeCycleMixin {}
