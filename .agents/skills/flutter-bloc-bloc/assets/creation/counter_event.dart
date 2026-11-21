sealed class CounterEvent {
  const CounterEvent();
}

final class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

final class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}
