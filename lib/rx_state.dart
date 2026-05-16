/// API pública do pacote [rx_state].
///
/// No app principal use um único import:
/// ```dart
/// import 'package:rx_state/rx_state.dart';
/// ```
///
/// Isso expõe reatividade ([RxValue], [Rxb], …), [RxView] e [GetIt] para
/// bindings/registros sem precisar declarar `get_it` separadamente no app.
library;

export 'package:get_it/get_it.dart';

export 'rx.dart';
export 'rxbuilder.dart';
export 'rx_lifecycle.dart';
export 'rxview.dart';
