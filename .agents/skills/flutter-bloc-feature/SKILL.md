---
name: flutter-bloc-feature
description: "Trigger: Flutter Bloc feature, Cubit, Bloc, feature scaffolding, Mason brick. Plan or scaffold a Bloc feature with explicit state and dependency choices."
license: MIT
metadata:
  author: plasenca-d
  version: "1.0"
---

## Activation Contract

Activate when creating, planning, or reviewing a Flutter feature that uses Bloc or Cubit.

## Hard Rules

- Use immutable state snapshots and explicit intent inputs: domain-intent methods for Cubit, typed past-tense events for Bloc. For Cubit, define the initial state, legal loading/success/failure transitions, equality behavior, repository constructor dependencies, UI listeners, and lifecycle owner before scaffolding.
- Choose Cubit for direct method-driven transitions; choose Bloc when named events, event payloads, traceability, or event-level concurrency matter.
- For event-driven Bloc, define past-tense typed event classes, pass the initial state to `super`, register each input with `on<Event>`, and emit only from handlers in response to events.
- Treat Bloc's default event processing as concurrent; choose `concurrent`, `sequential`, `droppable`, or `restartable` per handler when ordering, duplicate work, cancellation, or races matter. Use custom debounce/throttle transformers only with documented semantics and tests.
- Keep transformer scope and interactions explicit when multiple event types update one resource; do not assume ordering across separate handlers.
- Keep async orchestration in the business-logic class and I/O/mapping in constructor-injected repositories. Preserve useful data during refresh failures when the feature needs it.
- Keep rendering state separate from one-shot UI effects: builders/selectors render; listeners handle navigation, dialogs, snackbars, and analytics.
- Model explicit states and use `basic`, `equatable`, or `freezed` only when the project supports the needed dependencies.
- Use the feature name consistently in directories, types, files, events, and states.
- Never claim Mason ran. Check availability first; otherwise provide a manual file plan and the command a developer can run later.

## Decision Gates

| Need | Choice |
| --- | --- |
| Direct intent methods and no event-level semantics? | `cubit`/`hydrated_cubit`/`replay_cubit`; specify immutable state and method-to-state transitions. |
| Event payloads, traceability, or event-level concurrency? | `bloc`/`hydrated_bloc`/`replay_bloc`; retain an explicit event boundary. |
| Can matching events overlap safely and commute? | Keep default `concurrent`; otherwise select and record the required `bloc_concurrency` transformer semantics. |
| Is a high-frequency input losing intermediate values acceptable? | Consider an intentional debounce/throttle or `restartable`; document timing, cancellation, and test behavior. |
| Persistence or replay required? | Select the matching hydrated/replay type only when its dependency and behavior are requested. |
| Async state has refresh, empty, or failure cases? | Define status, retained data, error, and retry semantics before generating files. |
| State-generation convention? | `basic`, `equatable`, or `freezed`, matching existing project conventions. |

## Execution Steps

1. Normalize the feature name and select Cubit vs Bloc from behavior, not file-count preference.
2. Define state shape, equality, initial state, legal transitions, intent methods/events, and repository constructor dependencies.
3. For Cubit, record the side-effect boundary and provider/disposal owner; for Bloc, record event payload and concurrency requirements.
4. Select brick variables `name`, `type`, and `style`; verify Mason/brick availability.
5. Generate only when available; otherwise describe the equivalent files and exact deferred command.
6. Report choices, assumptions, transition/state plan, ownership, and generated or manual outputs.

## Output Contract

Return the selected type, state style, names, repository inputs, generation status, and file plan. Distinguish completed generation from instructions.

## References

- [Local upstream brick reference](references/flutter-bloc-feature-brick.md)
