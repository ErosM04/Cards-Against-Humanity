# Cubit reference

Use this file for the reasoning behind the runtime rules in `SKILL.md`. A Cubit is a small state machine: callers invoke named methods, the Cubit computes the next immutable snapshot, and the UI observes the resulting stream. It is not a bag of mutable fields and it is not a replacement for a repository.

## API facts and mental model

`Cubit<State>` extends `BlocBase<State>`. The constructor supplies the initial state through `super(initialState)`. `state` is the current snapshot; `stream` emits subsequent state changes for subscribers. A public method such as `retry`, `load`, or `toggleFavorite` is the Cubit's input surface. `emit(nextState)` is protected and should be called only by the Cubit (or its subclass), never by widgets or repositories.

Each accepted emission can be observed as a `Change<State>` containing the current and next state. If `state == nextState`, the duplicate emission is ignored, so state equality is part of the observable contract. `BlocObserver` can observe changes and errors globally; use it for diagnostics, not as application behavior. A Cubit is a `Closable`, so the owner must close it when it is no longer needed.

## State design: snapshots, not commands

Prefer one immutable state object when a feature has more than one concern. Keep fields that can be rendered or used to decide behavior together, and make equality explicit with the project's established `Equatable`, `freezed`, or value-type convention. Do not mutate a list or map held by a prior state; create a new collection for every snapshot.

A practical async state often has:

```dart
class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.error,
  });

  final ProfileStatus status;
  final Profile? profile;
  final Object? error;
}
```

Use a sealed-state family instead when illegal combinations must be impossible (`Initial`, `Loading`, `Success`, `Failure`). Decide deliberately whether refresh loading keeps prior data and whether a failure replaces or preserves it. Never use a nullable `isLoading` plus an unrelated error flag without defining their valid combinations.

Name methods after user or domain intent (`loadProfile`, `saveProfile`, `retry`), not implementation (`setLoading`, `setData`, `updateState`). Intent methods make transitions reviewable and prevent arbitrary callers from creating impossible states.

## Async work and errors

Inject a repository in the constructor. The Cubit owns orchestration and state transitions; the repository owns transport, caching, mapping, and domain-facing errors.

```dart
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    emit(ProfileState(status: ProfileStatus.loading, profile: state.profile));
    try {
      final profile = await _repository.fetchProfile();
      emit(ProfileState(status: ProfileStatus.success, profile: profile));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ProfileState(
        status: ProfileStatus.failure,
        profile: state.profile,
        error: error,
      ));
    }
  }
}
```

Catch only errors the feature can represent or deliberately map. Preserve the stack trace when reporting. Do not emit after `close`; for long-running work, define cancellation or ownership behavior rather than relying on a late callback. If multiple calls can overlap, document whether last completion wins, calls are ignored while loading, or requests are cancelled. When event payloads and standardized event-level concurrency/transformations are central, use Bloc instead of inventing an event queue around Cubit.

## Flutter integration and side effects

Provide route-scoped Cubits with `BlocProvider` so construction and disposal follow the widget lifecycle. Use `BlocProvider.value` only when handing an already-owned instance to another subtree; it does not create or close that instance. For manually constructed Cubits, the creating owner must call `close`.

Use `BlocBuilder` (or `BlocSelector`) for deterministic rendering from state. Use `BlocListener` for one-time effects such as navigation, dialogs, snackbars, analytics, or focus changes. Keep effects out of `build`, and do not overload state with transient commands that can replay on rebuild. If both rendering and effects are needed, compose `BlocConsumer` or separate builder/listener responsibilities clearly.

## Testing and diagnostics

Test the public method contract, not private implementation details. Given an initial state, assert the exact ordered states for success, failure, retry, empty data, and refresh-with-existing-data paths. Use a fake repository to control results and errors. Assert that invalid input does not produce an unintended transition and that closing prevents further work. Add an observer-based diagnostic only when transition/error visibility is itself the behavior under investigation.

## Cubit versus Bloc

Choose Cubit when a small set of named methods expresses the feature's intent, event history is not a product requirement, and direct state transitions are easier to read than an event type hierarchy. Cubit has less ceremony and is a good fit for local form state, toggles, simple filters, and request orchestration.

Choose Bloc when inputs need explicit event types and payloads, event history/traceability matters for debugging or audit, multiple event sources must be distinguished, or event-level concurrency transformations are required. Bloc's extra ceremony buys a visible event boundary and richer control; do not choose it merely because a feature is important. Conversely, do not choose Cubit merely to avoid files when the missing event boundary would make behavior ambiguous.

## Anti-patterns

- Mutable state objects, in-place collection edits, or equality that hides meaningful changes.
- Public `setState`/`emit` escape hatches that let callers bypass domain intent.
- Repository creation inside the Cubit or widget, which defeats dependency injection and test isolation.
- A single `bool isLoading` that cannot distinguish initial load, refresh, success, and failure.
- Navigation/snackbar calls from the Cubit or widget `build` method.
- A Cubit that silently swallows errors, logs without state, or continues emitting after disposal.
- A home-grown event bus, queue, or cancellation framework used to compensate for a Bloc-shaped problem.

## Sources

- [Bloc concepts: Cubit, state changes, streams, and usage](https://bloclibrary.dev/bloc-concepts/#cubit)
- [Bloc concepts: BlocObserver](https://bloclibrary.dev/bloc-concepts/#bloc-observer)
- [Cubit API](https://pub.dev/documentation/bloc/latest/bloc/Cubit-class.html)
- [BlocBase API](https://pub.dev/documentation/bloc/latest/bloc/BlocBase-class.html)
- [Change API](https://pub.dev/documentation/bloc/latest/bloc/Change-class.html)
- [BlocProvider API](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)
- [Flutter Bloc testing guide](https://bloclibrary.dev/testing/)
