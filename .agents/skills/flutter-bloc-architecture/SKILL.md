---
name: flutter-bloc-architecture
description: "Trigger: Flutter Bloc architecture, Bloc layering, repository boundaries, Bloc coupling. Design and review a maintainable Bloc architecture."
license: MIT
metadata:
  author: plasenca-d
  version: "1.0"
---

## Activation Contract

Activate for Flutter architecture planning or review involving Bloc, Cubit, repositories, data providers, or presentation boundaries.

## Hard Rules

- Separate presentation, business logic, and data; keep repositories above data providers.
- Give business logic input through events/actions and constructor-injected repositories.
- Do not create sibling Bloc-to-Bloc dependencies. Connect through presentation listeners or shared domain/data streams.
- Do not turn this skill into a feature generator; hand scaffolding to `flutter-bloc-feature`.

## Decision Gates

| Question | Choose |
| --- | --- |
| Does code retrieve or transform external data? | Data provider for raw access; repository for coordination and transformation. |
| Must two Blocs react to each other? | Prefer presentation coordination or a shared reactive repository; avoid direct coupling. |

## Execution Steps

1. Map the feature's presentation, business-logic, repository, and provider responsibilities.
2. Identify dependencies and move cross-layer work to the lowest suitable layer.
3. Define state inputs/outputs and repository interfaces before implementation.
4. Report boundary decisions, coupling risks, and unresolved trade-offs.

## Output Contract

Return a concise layer map, dependency direction, coupling assessment, and implementation questions. Name every repository dependency explicitly.

## References

- [Local architecture reference](references/architecture.md)
