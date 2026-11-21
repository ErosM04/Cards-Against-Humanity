// Template: inject a stream whose ownership and cancellation are explicit.
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

sealed class TickerEvent {
  const TickerEvent();
}

final class TickerStarted extends TickerEvent {
  const TickerStarted();
}

final class TickerState extends Equatable {
  const TickerState({this.value = 0, this.running = false, this.error});

  final int value;
  final bool running;
  final Object? error;

  @override
  List<Object?> get props => [value, running, error];
}

class TickerBloc extends Bloc<TickerEvent, TickerState> {
  TickerBloc(this._ticks) : super(const TickerState()) {
    on<TickerStarted>(_onStarted, transformer: restartable());
  }

  final Stream<int> Function() _ticks;

  Future<void> _onStarted(
    TickerStarted event,
    Emitter<TickerState> emit,
  ) async {
    emit(const TickerState(running: true));
    await emit.onEach<int>(
      _ticks(),
      onData: (value) => emit(TickerState(value: value, running: true)),
      onError: (error, stackTrace) {
        if (emit.isDone) return;
        addError(error, stackTrace);
        emit(TickerState(error: error));
      },
    );
    if (!emit.isDone) emit(TickerState(value: state.value));
  }
}
