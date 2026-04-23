import 'package:flutter/widgets.dart';

/// Lightweight state-management inspired by flutter_bloc's Cubit.
/// Backed by [ChangeNotifier] — zero external dependencies.
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(0);
///   void increment() => emit(state + 1);
/// }
/// ```
abstract class Cubit<T> extends ChangeNotifier {
  T _state;
  T get state => _state;
  bool _closed = false;

  Cubit(this._state);

  /// Push a new state and rebuild all listeners.
  @protected
  void emit(T newState) {
    if (_closed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}

/// Rebuilds [builder] whenever the [cubit] emits a new state.
///
/// ```dart
/// CubitBuilder(
///   cubit: myCubit,
///   builder: (context, state) => Text('$state'),
/// )
/// ```
class CubitBuilder<C extends Cubit<S>, S> extends StatelessWidget {
  const CubitBuilder({
    super.key,
    required this.cubit,
    required this.builder,
  });

  final C cubit;
  final Widget Function(BuildContext context, S state) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cubit,
      builder: (context, _) => builder(context, cubit.state),
    );
  }
}
