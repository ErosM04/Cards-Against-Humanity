# Create an event-driven Bloc feature

Use this recipe when a feature needs named inputs, event traceability, or event-level concurrency decisions. The included Counter example is intentionally self-contained: typed past-tense events enter through `add`, handlers perform explicit event-to-state transitions, state is immutable and value-equal, the provider owns the Bloc, and `bloc_test` verifies the public event contract.

## Prerequisites

From the Flutter project root, add the runtime and test packages:

```sh
flutter pub add bloc flutter_bloc
flutter pub add --dev bloc_test
```

The recipe uses the `basic` state/event style, so it does not require `equatable`, `freezed`, or code generation.

## Target file tree

Copy the files from [`assets/creation`](../assets/creation) into this layout:

```text
lib/
├── main.dart
├── counter_bloc.dart
├── counter_event.dart
├── counter_state.dart
└── counter_page.dart
test/
└── counter_bloc_test.dart
```

The asset directory is a source template, not a generated output directory. Copy each Dart file, then run the project with your normal Flutter workflow.

## Copy and rename

1. Copy the six assets into `lib/` and `test/` as shown above.
2. Replace `Counter`/`counter` consistently in filenames, classes, imports, app text, event names, and test descriptions (for example, `CartBloc`, `CartItemAdded`, and `cart_event.dart`).
3. Keep events past tense because each event records something that happened. Replace `CounterIncremented` and `CounterDecremented` with feature-specific inputs such as `ItemsLoadRequested`, `CheckoutSubmitted`, or `RetryPressed`.
4. Register every event with `on<Event>` and keep the handler responsible for the matching event-to-state transition. Do not expose `emit` or call it from the widget.

## What the recipe demonstrates

- `CounterState` is a snapshot with a `const` constructor, final fields, `copyWith`, and manual `==`/`hashCode` value equality. Equal snapshots are not emitted as meaningful changes by Bloc.
- `CounterEvent` is sealed. `CounterIncremented` and `CounterDecremented` are typed, past-tense event classes with const constructors and no untyped command payloads.
- `CounterBloc` passes the initial state to `super`, registers one `on<Event>` handler per event, receives `Emitter<CounterState>`, and emits only in response to its matching event.
- `CounterPage` uses `BlocProvider(create: ...)`, so the route-scoped provider constructs and closes the Bloc. `BlocBuilder` renders state and the buttons call `add(...)`.
- The test adds each public event through `blocTest` and asserts the exact emitted snapshot.

Matching events use Bloc's default concurrent processing in this synchronous example, where overlap is harmless. For async work, choose deliberately: `sequential` for ordered writes, `droppable` for duplicate work that should be ignored, `restartable` for latest-only requests, or `concurrent` when overlap is safe. Keep the rationale next to the registration and test the chosen semantics.

## State style choices

`basic` is the smallest dependency footprint and is appropriate for this readable example. Manual value equality is explicit but becomes repetitive as state grows. With **Equatable**, add `equatable` and extend `Equatable`, then return every meaningful field from `props`. With **Freezed**, add `freezed` and `freezed_annotation`, configure `build_runner`, annotate the state/events, and use generated equality/copy helpers. Choose the style already used by the project; do not mix conventions within one feature.

## Adapt to repositories and async work

Inject a repository into the Bloc constructor instead of constructing it in the widget:

```dart
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc(this._repository) : super(const ItemsState()) {
    on<ItemsLoadRequested>(_onLoadRequested);
  }

  final ItemsRepository _repository;
}
```

Add explicit status (`initial`, `loading`, `success`, `failure`), data, and error semantics when work can fail. In a handler, emit loading, await the repository, then emit success or a mapped failure. Decide whether refresh loading/failure retains existing data, catch only errors the feature can represent, preserve stack traces with `addError`, and never emit after the Bloc is closed. Select an event transformer when ordering, duplication, cancellation, or stale responses matter. Use `BlocListener` for one-shot effects such as navigation or snackbars; keep I/O and effects out of `build` and handlers.

## Optional Mason path

If the project has Mason and the upstream brick available, inspect them first (`mason --version`, then `mason list`) and run this command yourself when appropriate:

```sh
mason make flutter_bloc_feature --name counter --type bloc --style basic
```

This guide does not claim that Mason ran. Treat the command as an optional alternative to copying the local assets, and review the brick output against the project's event, state, dependency, concurrency, and lifecycle conventions before using it.
