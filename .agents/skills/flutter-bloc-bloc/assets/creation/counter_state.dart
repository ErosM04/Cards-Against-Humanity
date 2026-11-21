class CounterState {
  const CounterState({this.value = 0});

  final int value;

  CounterState copyWith({int? value}) {
    return CounterState(value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CounterState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
