---
name: flutter-bloc-bloc
description: "Trigger: Flutter Bloc, event-driven Bloc, Bloc handlers, event transformers. Implement and review typed event-to-state flows with explicit concurrency and lifecycle contracts."
license: MIT
metadata:
  author: plasenca-d
  version: "1.0"
---

## Activation Contract

Activate when implementing, reviewing, or refactoring a Flutter `Bloc<Event, State>`, its event/state models, handlers, transformer choices, repository boundary, or widget integration. Read [the local Bloc reference](references/bloc.md) for API facts and [the creation recipe](references/creation.md) when building a Bloc from scratch.

## Hard Rules

- Use immutable, value-equal state snapshots and noun-based state types; pass the initial state to `super`.
- Define past-tense, typed event classes and register each with `on<Event>`; handlers receive the event and `Emitter` and emit state only in response to that event.
- Treat the default event processing as concurrent. Select `sequential`, `droppable`, `restartable`, or `concurrent` deliberately when ordering, load, or stale work matters; custom debounce/throttle transformers require an explicit rationale.
- Inject repositories through the Bloc constructor; keep I/O and mapping out of widgets and do not couple sibling Blocs directly.
- Split UI rendering (`BlocBuilder`/selectors) from one-shot effects (`BlocListener`); make the provider/owner responsible for lifecycle and closure.
- Preserve error context and test ordered event-to-state behavior with `blocTest`; wait for asynchronous work before asserting.

## Decision Gates

| Question | Choice |
| --- | --- |
| Do inputs need named payloads, traceability, multiple sources, or event-level concurrency? | Use Bloc; otherwise evaluate Cubit. |
| Can events overlap safely? | Keep `concurrent`; otherwise choose a transformer whose semantics match the requirement. |
| Is this a rendering state or a one-shot effect? | Builder/selector for rendering; listener for effects. |
| Who owns the Bloc? | `BlocProvider` for widget scope; otherwise document and close the creating owner. |

## Execution Steps

1. Map event inputs, immutable state snapshots, legal transitions, effects, repository interfaces, and lifecycle owner.
2. Implement typed event classes, initial `super` state, `on<Event>` handlers, and explicit transformer choices.
3. When creating from scratch, follow `references/creation.md` and adapt the matching files under `assets/creation/` before adding feature-specific behavior.
4. Wire providers and the builder/listener split without direct Bloc-to-Bloc dependencies.
5. Test success, failure, empty/refresh, duplicate-state, ordering, overlap, and closure behavior with controlled async fakes.
6. Report the pipeline, transformer rationale, state/equality contract, ownership, side-effect boundary, and verification.

## Output Contract

Return the Bloc/event/state contract, event-to-state table, transformer decisions, injected dependencies, provider/lifecycle owner, UI split, tests, and unresolved trade-offs.

## References

- [Local Bloc reference](references/bloc.md)
- [Bloc creation recipe](references/creation.md)
