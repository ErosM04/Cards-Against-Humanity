# Bloc reference

Use this file for the reasoning and API detail behind the runtime rules in `SKILL.md`. A Bloc is an event-driven state machine: callers add typed events, handlers coordinate work, and subscribers observe immutable state snapshots. The event boundary is intentional ceremony, not a replacement for a repository or a license to put UI behavior in business logic.

## API facts and event pipeline

`Bloc<Event, State>` extends `BlocBase<State>`. The constructor must pass the initial state to `super(initialState)`. Callers enter through `add(event)`; register typed handlers with `on<Event>((event, emit) { ... })`. A handler receives the matching event payload and an `Emitter<State>`. State changes must be emitted by handlers in response to events, never by widgets or repositories.

The useful pipeline is:

1. **Event added** — a UI action, lifecycle signal, stream adapter, or domain source calls `add`.
2. **Event observation** — `onEvent`/`BlocObserver.onEvent` records the accepted event for diagnostics.
3. **Event transformer** — the registered handler's transformer decides whether this event runs now, waits, is dropped, or supersedes prior work.
4. **Typed handler** — `on<SpecificEvent>` receives the payload and `Emitter`; it validates/orchestrates through injected collaborators.
5. **Emitted states** — the handler emits immutable snapshots representing observable progress and outcomes.
6. **Transition/change observation** — `onTransition` observes the event plus current/next state; `onChange` observes state changes for any `BlocBase`.

This boundary makes inputs traceable, gives payloads a stable home, distinguishes multiple event sources, enables audit/debugging, and puts concurrency policy at the event level. It also lets an observer explain *which event* caused a transition instead of only showing a method call or final state. The default event processing is concurrent, so independent handlers may overlap and complete out of order; never assume sequential behavior merely because `add` calls were ordered.

`onDone` reports handler completion (including optional error/stack information), and `onError` reports an error. `BlocObserver` can centralize these observations across Blocs and Cubits. Keep observability diagnostic: application behavior belongs in handlers and state. An exception not handled by a handler reaches `onError`; catch only errors that the feature can represent or deliberately map, preserve the stack trace, and emit a useful failure state when appropriate.

A duplicate state where `state == nextState` is ignored. Equality is therefore observable behavior: use immutable values and include every field whose change should notify subscribers.

## Typed events, handlers, and names

Use one event type per meaningful input, with payloads on the event rather than hidden mutable fields. Name events in past tense because they describe something that occurred: `ProfileLoadRequested`, `ProfileRefreshRequested`, `ProfileSaved`, `RetryPressed`. Name state types as nouns or snapshots (`ProfileState`, `ProfileLoadState`), not commands. Keep event and state names feature-prefixed and unambiguous.

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoadRequested,
        transformer: droppable());
    on<ProfileRefreshRequested>(_onRefreshRequested,
        transformer: restartable());
  }

  final ProfileRepository _repository;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.loading());
    try {
      final profile = await _repository.fetchProfile();
      emit(state.success(profile));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure(error));
    }
  }
}
```

Use the project's established `Equatable`, `freezed`, sealed-class, or value-type convention. Do not mutate lists/maps held by a prior state; create new collections for each snapshot. Decide whether refresh loading retains existing data and whether failure retains it. Make legal combinations explicit instead of combining unrelated nullable flags that permit impossible states.

Handlers own orchestration and state transitions. Repositories own transport, caching, mapping, and domain-facing error translation. Inject the repository and other collaborators through the Bloc constructor; do not instantiate them in a handler or widget. Do not call `emit` from a repository, expose a public emit escape hatch, or emit after the Bloc is closed. If work can outlive the Bloc, define cancellation or ownership behavior rather than relying on a late callback.

## Event concurrency and transformers

`bloc_concurrency` provides the standard event transformers. Choose per handler, based on the event's semantics, and document the reason next to the registration:

| Transformer | Semantics | Good fit | Risk to call out |
| --- | --- | --- | --- |
| `concurrent()` | Process events in parallel; completions may interleave. This is the default. | Independent reads or operations that commute. | Races, stale responses, and last-completion-wins behavior. |
| `sequential()` | Queue matching events and process one after another. | Writes, ordered commands, pagination where order matters. | Backlog and latency under a burst. |
| `droppable()` | Ignore a new matching event while one is active. | Idempotent initial load, submit buttons, refresh where duplicate work is wasteful. | A legitimate event can be discarded. |
| `restartable()` | Cancel/supersede prior handler work and process the newest event. | Search/filter/typeahead or refresh where only the latest request matters. | The underlying operation must tolerate cancellation/supersession; side effects may already have happened. |

```dart
on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
on<SavePressed>(_onSavePressed, transformer: sequential());
on<RefreshRequested>(_onRefreshRequested, transformer: droppable());
```

Use `concurrent()` only after checking that overlap is safe and state updates cannot become stale. Do not select a transformer because it is fashionable or because a handler is async. Custom debounce/throttle transformers are valid intentional choices for high-frequency sources, but specify their timing, cancellation, lossiness, and test behavior; do not silently hide a race with an ad hoc stream utility.

Transformer scope matters: a transformer on `on<A>` controls matching `A` events, not automatically every event in the Bloc. If several event types update one resource, reason about their interactions explicitly and choose registrations/coordination that preserve the resource invariant.

## Cubit versus Bloc

Cubit is the better fit when a small set of named methods expresses direct intent, event history is not needed, and event-level concurrency is not a meaningful contract. It has less ceremony and works well for local form state, toggles, simple filters, and straightforward request orchestration.

Bloc is worth the event classes and handler registrations when payloads need explicit types, several sources must be distinguished, audit/debug traceability matters, or each input needs a concurrency policy. Event names make causality reviewable and let tests assert input-to-output sequences. Do not choose Bloc merely because a feature is important, and do not force Cubit merely to avoid event files when overlapping inputs or event history would otherwise be ambiguous.

## Flutter integration and lifecycle

Provide a route- or subtree-scoped Bloc with `BlocProvider(create: ...)` so the provider constructs and closes it with the widget lifecycle. Use `BlocProvider.value` only to pass an already-owned Bloc to another subtree; it does not assume ownership or close that instance. For manually constructed Blocs, the creating owner must call `close`.

Use `BlocBuilder` or `BlocSelector` for deterministic rendering from state. Use `BlocListener`/`MultiBlocListener` for one-shot effects such as navigation, dialogs, snackbars, focus changes, and analytics. Keep effects out of `build`, handlers, and repositories: handlers emit semantic state; listeners interpret that state at the UI boundary. If both responsibilities are needed, compose `BlocConsumer` or keep separate builder/listener widgets with clear predicates. Do not make sibling Blocs depend directly on one another; coordinate in presentation or through a shared repository/domain stream.

## Testing and diagnostics

Test the public event contract with `blocTest`: construct a controlled fake repository, add events in `act`, and assert exact ordered states in `expect`. Cover initial/no-event behavior, success, empty data, mapped failures, refresh with retained data, duplicate-state suppression, invalid input, ordering, overlap, cancellation/supersession, and closure. For async handlers, `blocTest` normally waits for emitted states, but explicitly await or use `wait` when the behavior includes timers, debounce, delayed work, or settling after an event; never assert a race by sleeping an arbitrary amount.

Use an observer test only when event/transition/change/error visibility is part of the contract or when diagnosing a failure. Assert error state and error observation separately when both matter. Ensure fakes complete or cancel before teardown so a closed Bloc cannot receive late emissions.

## Anti-patterns

- Mutable state, in-place collection edits, or equality that hides a meaningful field change.
- Generic `SetState`, `Update`, or `Load` events that erase intent and payload type safety.
- Calling `emit` or repository methods from widgets, or bypassing explicit event intent with untyped/generic event payloads.
- Registering every event with the default concurrent transformer without checking races or stale results.
- Rebuilding a debounce/throttle/cancellation framework without documenting its semantics and tests.
- Creating repositories in the Bloc/widget, or coupling sibling Blocs directly to orchestrate flow.
- Navigation, snackbars, dialogs, or analytics in a handler or `build` method.
- Swallowing exceptions, losing stack traces, logging without a state outcome, or continuing after close.
- Treating `BlocObserver` hooks as application state or assuming `onChange` alone identifies the triggering event.

## Sources

- [Bloc concepts: Bloc](https://bloclibrary.dev/bloc-concepts/#bloc)
- [Bloc concepts: events and transitions](https://bloclibrary.dev/bloc-concepts/#events)
- [Bloc concepts: BlocObserver](https://bloclibrary.dev/bloc-concepts/#bloc-observer)
- [Bloc API](https://pub.dev/documentation/bloc/latest/bloc/Bloc-class.html)
- [BlocBase API](https://pub.dev/documentation/bloc/latest/bloc/BlocBase-class.html)
- [Emitter API](https://pub.dev/documentation/bloc/latest/bloc/Emitter-class.html)
- [bloc_concurrency README](https://github.com/felangel/bloc/tree/master/packages/bloc_concurrency)
- [Flutter Bloc testing guide](https://bloclibrary.dev/testing/)
- [BlocProvider API](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)
