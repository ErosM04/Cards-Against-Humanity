# Rebuild control

Choose a rendering surface from the state actually needed by the widget. Rebuild control changes when Flutter asks a subtree to render; it does not change which states the Bloc emits or make an invalid state safe.

## Decision tree

```text
Does the widget render multiple fields or the whole state?
├─ Yes: BlocBuilder<Bloc, State>.
│   └─ Is a measured predicate needed for this exact subtree?
│       ├─ No: omit buildWhen.
│       └─ Yes: add buildWhen(previous, current), document the fields it ignores,
│              and verify ignored changes cannot make this subtree stale.
└─ No: can the widget render one immutable projection?
    ├─ Yes: BlocSelector<Bloc, State, Selected> or context.select<Bloc, Selected>.
    │       Ensure Selected has stable value equality and is immutable.
    └─ No: extract a smaller state/view model or split the rendering boundary;
            do not select a mutable object and hope identity is stable.
```

## API facts

**Direct upstream fact:** `BlocBuilder` invokes its builder on state changes and accepts `buildWhen` as an optional previous/current predicate. The Flutter Bloc README and concepts documentation describe `buildWhen` as a performance optimization and explicitly warn that it provides no security guarantee.

**Direct upstream fact:** `BlocSelector` selects a value from the full state and compares the selected result to decide whether to rebuild. Its implementation requires the selected value to be immutable so equality can be trusted.

**Direct upstream fact:** `context.select` lets a widget rebuild only when its selected projection changes. It is useful for a small leaf, while `BlocSelector` makes the projection explicit as a widget boundary.

**Direct upstream fact:** `BlocBase.emit` suppresses equal states after the initial state. If a state mutates a list in place, or equality omits a meaningful field, listeners can miss a real change before any builder predicate runs.

See `packages/flutter_bloc/lib/src/bloc_builder.dart`, `packages/flutter_bloc/lib/src/bloc_selector.dart`, `packages/flutter_bloc/README.md`, `docs/src/content/docs/flutter-bloc-concepts.mdx`, and `packages/bloc/lib/src/bloc_base.dart` in the upstream source links in `performance-model.md`.

## Practical patterns

### Select a primitive or immutable projection

```dart
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<InboxBloc, int>((bloc) => bloc.state.unread);
    return Text('$unread');
  }
}
```

If a projection contains several values, return a project value type with explicit equality. Do not return a freshly allocated object whose equality is identity-based unless every state change should rebuild it.

### Use `buildWhen` narrowly

```dart
BlocBuilder<InboxBloc, InboxState>(
  buildWhen: (previous, current) =>
      previous.messages != current.messages ||
      previous.status != current.status,
  builder: (context, state) => MessageList(state.messages),
)
```

This is appropriate only when `MessageList` is intentionally independent of every omitted field. Prefer a selector when the widget can express its dependency as one projection.

## Anti-patterns

- Returning a mutable `List`, `Map`, or model from a selector and mutating it later.
- Using identity equality for a selected wrapper while allocating a new wrapper on every state emission.
- Omitting a state field from `buildWhen` while the builder reads it indirectly through a closure, inherited object, or side channel.
- Using `buildWhen` to prevent access to a state field, enforce authorization, or repair invalid combinations.
- Wrapping an entire screen in one `BlocBuilder` when independent leaves can select primitive values.
- Splitting a Bloc solely to reduce a counter without measuring ownership, transition, and lifecycle costs.
- Emitting a new state for every keystroke or timer tick when the UI only needs the latest debounced value.
- Doing expensive JSON mapping, sorting, or filtering inside `build`; map in the repository/Bloc and select a ready value.

## Review checklist

- [ ] Name the exact state fields each builder or selector reads.
- [ ] Confirm state and selected values are immutable and value-equal.
- [ ] Confirm no meaningful field is excluded by `buildWhen`.
- [ ] Confirm a selector is smaller than the state and stable across equal inputs.
- [ ] Count rebuilds in the actual screen before and after; do not infer from code shape.
- [ ] Confirm the optimization did not move domain work into `build` or a widget callback.
- [ ] Confirm one-shot effects remain in listeners, not render predicates.

## Sources

- `packages/flutter_bloc/lib/src/bloc_builder.dart` — builder and `buildWhen` implementation.
- `packages/flutter_bloc/lib/src/bloc_selector.dart` — selector comparison and immutability contract.
- `packages/flutter_bloc/README.md` — `BlocBuilder`, `BlocSelector`, and `context.select` usage.
- `docs/src/content/docs/flutter-bloc-concepts.mdx` — widget integration concepts.
- `packages/bloc/lib/src/bloc_base.dart` — equal-state suppression.
