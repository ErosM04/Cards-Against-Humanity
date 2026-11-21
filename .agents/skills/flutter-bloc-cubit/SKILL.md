---
name: flutter-bloc-cubit
description: "Trigger: Flutter Cubit, Cubit state, Cubit feature, Cubit refactor. Implement and review method-driven Cubit state flows with explicit lifecycle and UI contracts."
license: MIT
metadata:
  author: plasenca-d
  version: "1.0"
---

## Activation Contract

Activate when implementing, reviewing, or refactoring a Flutter `Cubit`, its state model, repository boundary, or widget integration. Read [the local Cubit reference](references/cubit.md) for API facts and [the creation recipe](references/creation.md) when building a Cubit from scratch.

## Hard Rules

- Model immutable state snapshots; expose domain-intent methods, not generic `setState`-style setters.
- Inject repositories and other collaborators through the constructor; keep I/O and transformation out of widgets.
- Use explicit loading, success, and failure states (or equivalent status fields); preserve useful data when a refresh fails.
- Use `BlocListener`/`MultiBlocListener` for one-shot effects and `BlocBuilder`/selectors for rendering; emit semantic state data for listeners, but never perform navigation, dialog, or snackbar calls in the Cubit or builder.
- Let `BlocProvider` own route-scoped Cubits and close manually created Cubits when their owner is done.
- Keep `emit` inside the Cubit; do not emit after disposal or hide errors with broad catches.

## Decision Gates

| Question | Choice |
| --- | --- |
| Are transitions naturally triggered by direct intent methods? | Use Cubit. |
| Do event payloads, event traceability, replay, or event-level concurrency matter? | Use Bloc; do not force Cubit. |
| Does state represent async work? | Define a status plus data/error semantics before writing methods. |
| Who creates the Cubit? | Use `BlocProvider` for widget-owned scope; otherwise document and close the owner. |

## Execution Steps

1. Identify intents, observable states, side effects, lifecycle owner, and repository interfaces.
2. Choose a state representation and equality strategy; define the initial state and legal transitions.
3. When creating from scratch, follow `references/creation.md` and adapt the matching files under `assets/creation/` before adding feature-specific behavior.
4. Implement public domain-intent methods that guard lifecycle, await repository calls, and emit immutable snapshots.
5. Wire the Cubit through `BlocProvider`; render with builders/selectors and react with listeners.
6. Test method-to-state sequences, success/failure boundaries, duplicate-state behavior, and closure; use an observer when diagnosing transitions.
7. Report the state contract, ownership, side-effect boundary, and why Cubit (or Bloc) was selected.

## Output Contract

Return the Cubit class and state shape, method-to-transition table, injected dependencies, provider/lifecycle owner, UI listener/builder split, tests or test plan, and the Cubit-vs-Bloc decision with its trade-off.

## References

- [Local Cubit reference](references/cubit.md)
- [Cubit creation recipe](references/creation.md)
