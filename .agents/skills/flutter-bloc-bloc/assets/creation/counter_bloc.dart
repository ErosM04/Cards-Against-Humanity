import 'package:bloc/bloc.dart';

import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
  }

  void _onIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) {
    emit(state.copyWith(value: state.value + 1));
  }

  void _onDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) {
    emit(state.copyWith(value: state.value - 1));
  }
}
