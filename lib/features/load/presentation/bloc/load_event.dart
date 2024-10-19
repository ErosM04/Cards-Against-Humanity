part of 'load_bloc.dart';

@immutable
sealed class LoadEvent {
  const LoadEvent();
}

final class LoadStart extends LoadEvent {
  const LoadStart();
}
