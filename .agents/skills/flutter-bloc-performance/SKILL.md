---
name: flutter-bloc-performance
description: "Trigger: Flutter Bloc performance, rebuilds, selectors, event concurrency, pagination, search, profiling. Optimize Bloc-specific rendering and async work without changing domain behavior."
license: MIT
metadata:
  author: plasenca-d
  version: "1.0"
---

## Activation Contract

Activate when a Flutter `Bloc` feature has avoidable rebuilds, duplicate/equal states, overlapping events, stream lifetime risk, pagination/search load, cache-boundary questions, or jank/memory symptoms. Read the matching local reference before changing code.

## Hard Rules

- Preserve domain behavior; optimize observable work, not correctness shortcuts.
- Make state immutable and value-equal; never rely on `buildWhen` for state security.
- Scope UI updates with `BlocSelector`/`context.select`; use `buildWhen` only as a measured render filter.
- Treat event processing as concurrent by default; choose a per-handler transformer deliberately.
- Await `emit.onEach`/`emit.forEach`; define cancellation and closure ownership for long-lived streams.
- Keep pagination, debounce, cache, and mapping in injected repositories/Blocs, not widgets.
- Measure before/after with observer metrics and profile-mode DevTools; label local recommendations as such.

## Decision Gates

| Question | Decision |
| --- | --- |
| Does a widget need all state? | `BlocBuilder`; otherwise select the smallest immutable value. |
| Can matching events overlap safely? | `concurrent`; otherwise use `sequential`, `droppable`, or `restartable`. |
| Is work latest-only, append-only, or stream-backed? | Use search/cache, paginated guard, or awaited stream recipe respectively. |

## Execution Steps

1. Map state equality, rebuild surfaces, event rates, async ownership, and repository boundaries.
2. Apply the smallest matching recipe under `references/` and adapt its template under `assets/`.
3. Instrument before/after; verify state transitions, cancellation, list guards, and UI rebuild counts.
4. Report direct upstream facts separately from local engineering recommendations.

## Output Contract

Return changed surfaces, equality/rebuild decision, transformer and cancellation rationale, repository/cache boundary, measurements, verification checklist, and remaining trade-offs.

## References

- [Performance model](references/performance-model.md)
- [Rebuild control](references/rebuild-control.md)
- [Concurrency and streams](references/concurrency-and-streams.md)
- [Scalability recipes](references/scalability-recipes.md)
- [Profiling](references/profiling.md)
