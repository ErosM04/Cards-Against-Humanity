# Performance model

Use this reference to separate what the Bloc sources directly establish from local engineering guidance. The upstream project distributes performance behavior across API docs, implementation, tutorials, and examples; it does not provide a dedicated performance chapter.

## Scope

This skill is about reducing Bloc-specific work while preserving the event-to-state contract:

- avoid unnecessary widget rebuilds and duplicate state notifications;
- make equality and immutable collection ownership explicit;
- bound overlapping event and stream work;
- scale pagination, typeahead search, and cache access;
- keep repositories responsible for I/O, mapping, and cache policy;
- diagnose state, transition, rebuild, frame, and memory behavior.

It is not a generic Flutter micro-optimization guide. Do not use a Bloc optimization to hide an invalid state, skip required persistence, or move domain behavior into a widget predicate.

## Evidence matrix

| Concern | Direct upstream fact | Source | Practical consequence |
| --- | --- | --- | --- |
| Render filtering | `buildWhen` receives previous/current state and controls whether the builder runs; it is for performance and provides no state-security guarantee. | `packages/flutter_bloc/README.md`; `docs/src/content/docs/flutter-bloc-concepts.mdx` | Keep state complete and valid; use `buildWhen` only after identifying a render surface. |
| Projection | `BlocSelector` compares the selected value and rebuilds when that selected value changes; the selected value must be immutable. | `packages/flutter_bloc/lib/src/bloc_selector.dart`; concepts docs | Select the smallest stable value needed by a widget. |
| Context projection | `context.select` scopes widget updates to a selected part of state. | `packages/flutter_bloc/README.md`; concepts docs | Prefer a narrow selector over rebuilding a broad subtree. |
| Equal state and collections | `BlocBase.emit` does not notify listeners when the new state equals the current state after the initial emission; the FAQ recommends value equality and copying `List`/`Map` values rather than mutating them. | `packages/bloc/lib/src/bloc_base.dart`; `docs/src/content/docs/faqs.mdx` | Equality is observable behavior; include all fields whose changes matter and copy collections. |
| Event overlap | Bloc event processing is concurrent by default; an event transformer is applied per handler registration. | `packages/bloc/lib/src/bloc.dart`; `packages/bloc_concurrency/README.md` | Never infer ordering from the order of `add` calls; choose a handler policy. |
| Stream handlers | `emit.onEach` and `emit.forEach` connect a stream to state emissions; the returned future must be awaited, and handler completion/cancellation determines lifetime. | `packages/bloc/lib/src/emitter.dart` | Await stream work and make restart/close behavior explicit. |
| Pagination | The infinite-list tutorial/example uses throttled, droppable fetches, a batch size, a reached-max guard, and `ListView.builder`. | `docs/src/content/docs/tutorials/flutter-infinite-list.mdx`; `examples/flutter_infinite_list` | Bound request rate and avoid duplicate appends while preserving ordered pages. |
| Search | The GitHub search example debounces input, uses latest-only `switchMap`, and consults a repository cache. | `docs/src/content/docs/tutorials/github-search.mdx`; `examples/github_search` | Treat typeahead as latest-wins and put cache policy below the Bloc. |
| Boundaries | Architecture guidance keeps repositories behind a boundary and discourages direct Bloc-to-Bloc coupling. | `docs/src/content/docs/architecture.mdx` | Optimize at the repository/Bloc boundary, not by making widgets own transport or sibling Blocs. |

## Direct versus inferred labels

Use **Direct upstream fact** when a statement follows from one of the source paths above or the linked API implementation. Use **Local engineering recommendation** for conclusions that require project context, measurement, or Flutter tooling. For example:

- **Direct upstream fact:** equal states are suppressed by `BlocBase.emit`.
- **Local engineering recommendation:** split a large state into multiple feature Blocs when profiling shows selector work is still expensive and the split preserves ownership.
- **Direct upstream fact:** default event processing is concurrent.
- **Local engineering recommendation:** use `sequential()` for a write because the domain requires ordering.
- **Direct upstream fact:** `BlocSelector` needs an immutable selected value.
- **Local engineering recommendation:** expose a small immutable view model instead of selecting a mutable list.

## Optimization order

1. Preserve the contract: state validity, event semantics, repository ownership, and lifecycle.
2. Measure the expensive surface: transition rate, equal-state rate, handler duration, request count, rebuild count, frame time, or memory retention.
3. Reduce the source of work: deduplicate input, debounce, cache, page, or choose a transformer.
4. Reduce the fan-out: select a smaller value, split a rendering subtree, or use a render predicate.
5. Re-measure in the same scenario and mode. A lower rebuild count is not a win if stale data, dropped writes, or retained stream subscriptions result.

## Non-goals and boundaries

- `buildWhen` MUST NOT be used to protect sensitive state or repair a state model.
- A transformer MUST NOT replace domain conflict resolution or transactional repository behavior.
- A cache MUST NOT become a second source of truth without an invalidation policy.
- A debounce/throttle MUST NOT be added solely to make a flaky test pass.
- Profile-mode and DevTools workflow are local recommendations in `profiling.md`; they are not upstream Bloc performance guarantees.

## Verification checklist

- [ ] State equality includes every render-relevant field and no mutable collection is shared between snapshots.
- [ ] Every selector returns an immutable, appropriately granular value.
- [ ] Every transformer has a stated ordering, lossiness, cancellation, and side-effect rationale.
- [ ] Stream-backed handlers are awaited and stop on completion/close.
- [ ] Pagination cannot duplicate pages or fetch beyond the known end.
- [ ] Search cannot display a stale response for a newer query.
- [ ] Repository/cache ownership remains explicit.
- [ ] Before/after observations use the same scenario and measurement mode.

## Upstream sources

- [flutter_bloc README](https://github.com/felangel/bloc/blob/master/packages/flutter_bloc/README.md)
- [Flutter Bloc concepts](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/flutter-bloc-concepts.mdx)
- [BlocBuilder implementation](https://github.com/felangel/bloc/blob/master/packages/flutter_bloc/lib/src/bloc_builder.dart)
- [BlocSelector implementation](https://github.com/felangel/bloc/blob/master/packages/flutter_bloc/lib/src/bloc_selector.dart)
- [BlocBase implementation](https://github.com/felangel/bloc/blob/master/packages/bloc/lib/src/bloc_base.dart)
- [Bloc implementation](https://github.com/felangel/bloc/blob/master/packages/bloc/lib/src/bloc.dart)
- [Emitter implementation](https://github.com/felangel/bloc/blob/master/packages/bloc/lib/src/emitter.dart)
- [FAQ](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/faqs.mdx)
- [Architecture](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/architecture.mdx)
