# Create a Cubit feature

Use this recipe when a feature has a small, method-driven input surface. The included Counter example is deliberately self-contained: state is immutable and value-equal, the provider owns the Cubit, the widget only reads and renders state, and `bloc_test` verifies the public methods.

## Prerequisites

From the Flutter project root, add the runtime and test packages:

```sh
flutter pub add bloc flutter_bloc
flutter pub add --dev bloc_test
```

The recipe uses the `basic` state style, so it does not require `equatable`, `freezed`, or code generation.

## Target file tree

Copy the files from [`assets/creation`](../assets/creation) into this layout:

```text
lib/
├── main.dart
├── counter_cubit.dart
├── counter_state.dart
└── counter_page.dart
test/
└── counter_cubit_test.dart
```

The asset directory is a source template, not a generated output directory. Copy each Dart file, then run the project with your normal Flutter workflow.

## Copy and rename

1. Copy the five assets into `lib/` and `test/` as shown above.
2. Replace `Counter`/`counter` consistently in filenames, classes, imports, app text, and test descriptions (for example, `CartCubit` and `cart_state.dart`).
3. Keep the Cubit's public methods named after domain intent. Replace `increment` and `decrement` with methods such as `retry`, `loadItems`, or `toggleFavorite`; do not expose a generic setter or `emit`.
4. Keep `CounterPage` as the route entry point unless the feature is embedded in an existing route.

## What the recipe demonstrates

- `CounterState` is a snapshot with a `const` constructor, final fields, `copyWith`, and manual `==`/`hashCode` value equality. Equal snapshots are not emitted as meaningful changes by Bloc.
- `CounterCubit` passes the initial state to `super` and owns both method-driven transitions. There are no event classes: callers invoke `increment()` or `decrement()` directly.
- `CounterPage` uses `BlocProvider(create: ...)`, so the route-scoped provider constructs and closes the Cubit. `BlocBuilder` renders state; it does not mutate it.
- The test invokes each public method through `blocTest` and asserts the exact emitted snapshot.

## State style choices

`basic` is the smallest dependency footprint and is appropriate for this readable example. Manual value equality is explicit but becomes repetitive as state grows. With **Equatable**, add `equatable` and extend `Equatable`, then return every meaningful field from `props`. With **Freezed**, add `freezed` and `freezed_annotation`, configure `build_runner`, annotate the state, and use generated equality/copy helpers. Choose the style already used by the project; do not mix conventions within one feature.

## Adapt to repositories and async work

Inject a repository into the Cubit constructor instead of constructing it in the widget:

```dart
class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit(this._repository) : super(const ItemsState());

  final ItemsRepository _repository;
}
```

Add an explicit status (`initial`, `loading`, `success`, `failure`) and an error field when work can fail. In an intent method, emit loading, await the repository, then emit success or a mapped failure. Decide whether refresh loading/failure retains existing data, catch only errors the feature can represent, preserve stack traces with `addError`, and never emit after the Cubit is closed. Use `BlocListener` for one-shot effects such as navigation or snackbars; keep I/O and effects out of `build`.

## Optional Mason path

If the project has Mason and the upstream brick available, inspect them first (`mason --version`, then `mason list`) and run this command yourself when appropriate:

```sh
mason make flutter_bloc_feature --name counter --type cubit --style basic
```

This guide does not claim that Mason ran. Treat the command as an optional alternative to copying the local assets, and review the brick output against the project's state, dependency, and lifecycle conventions before using it.
