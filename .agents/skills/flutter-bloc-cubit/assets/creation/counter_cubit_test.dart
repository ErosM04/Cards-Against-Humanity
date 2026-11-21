import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import '../lib/counter_cubit.dart';
import '../lib/counter_state.dart';

void main() {
  group('CounterCubit', () {
    blocTest<CounterCubit, CounterState>(
      'emits an incremented value',
      build: CounterCubit.new,
      act: (cubit) => cubit.increment(),
      expect: () => [const CounterState(value: 1)],
    );

    blocTest<CounterCubit, CounterState>(
      'emits a decremented value',
      build: CounterCubit.new,
      act: (cubit) => cubit.decrement(),
      expect: () => [const CounterState(value: -1)],
    );
  });
}
