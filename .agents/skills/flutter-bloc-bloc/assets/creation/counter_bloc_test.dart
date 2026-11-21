import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import '../lib/counter_bloc.dart';
import '../lib/counter_event.dart';
import '../lib/counter_state.dart';

void main() {
  group('CounterBloc', () {
    blocTest<CounterBloc, CounterState>(
      'emits an incremented value when CounterIncremented is added',
      build: CounterBloc.new,
      act: (bloc) => bloc.add(const CounterIncremented()),
      expect: () => [const CounterState(value: 1)],
    );

    blocTest<CounterBloc, CounterState>(
      'emits a decremented value when CounterDecremented is added',
      build: CounterBloc.new,
      act: (bloc) => bloc.add(const CounterDecremented()),
      expect: () => [const CounterState(value: -1)],
    );
  });
}
