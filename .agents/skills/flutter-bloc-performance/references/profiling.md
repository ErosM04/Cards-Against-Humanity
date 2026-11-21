# Profiling and diagnostics

This file is **Local engineering guidance**, not an upstream Bloc performance guarantee. The upstream project provides observer hooks and runtime behavior, but no dedicated performance chapter, DevTools workflow, frame-jank guidance, memory playbook, performance CI, or benchmark claim for this skill. Adapt the workflow to the application's release process.

## What to measure

| Signal | Why it matters | Useful boundary |
| --- | --- | --- |
| Event count/rate and handler duration | Reveals bursty input, queue growth, or expensive orchestration. | `BlocObserver.onEvent`, `onDone`, and controlled timing around repository calls. |
| Transition/change count and equal-state rate | Shows whether the Bloc emits more snapshots than subscribers need. | `onTransition` for Bloc; `onChange` for Bloc/Cubit; state equality instrumentation in a diagnostic build. |
| Rebuild count by widget | Finds broad builders and ineffective selectors. | A temporary rebuild counter such as `assets/rebuild-counter/profile_selector.dart`. |
| Request count, cache hit/miss, page duplicates | Detects missing debounce, pagination guards, or cache policy. | Repository metrics tagged with normalized query/page. |
| Frame raster/build time and jank | Shows user-visible rendering cost, not merely Bloc throughput. | Flutter DevTools Performance view in profile mode on representative hardware. |
| Allocation/retained subscriptions and list growth | Finds mutable accumulation, unclosed streams, and cache leaks. | DevTools Memory view plus lifecycle/close logs. |

Upstream facts about observer hooks and state/transition/change visibility are described in the Bloc concepts docs, `packages/bloc/lib/src/bloc.dart`, and `packages/bloc/lib/src/bloc_base.dart`. The interpretation and tooling workflow below are local recommendations.

## Repeatable workflow

1. Reproduce a named scenario: initial load, rapid search typing, repeated pagination trigger, refresh during load, or stream restart.
2. Record the build mode, device/emulator, dataset size, query sequence, page size, cache state, and expected state transitions.
3. Add temporary diagnostic labels or an observer metric; avoid logging payloads or sensitive data.
4. Capture a baseline in profile mode with DevTools Performance and Memory views. Look for event bursts, handler overlap, rebuild fan-out, frame spikes, and retained subscriptions.
5. Apply one change: selector, equality fix, transformer, debounce/cache, page guard, or repository boundary adjustment.
6. Repeat the exact scenario and compare counts and frame/memory evidence. Remove instrumentation that is not part of an intentional diagnostic contract.

Do not use debug-mode timing as a release performance claim. Do not infer user-visible improvement from a lower transition count alone: a dropped write, stale result, or hidden error is a regression.

## Observer metrics

Keep observer code diagnostic and bounded:

- tag events/transitions by Bloc type and event/state type, not full payloads by default;
- measure durations with a monotonic timer around repository work;
- sample or aggregate high-frequency events to avoid the observer becoming the bottleneck;
- capture error and stack context separately from the failure state;
- include lifecycle close and stream subscription completion when diagnosing retention.

`BlocObserver` hooks are not an application state channel. If a metric changes behavior, move that behavior into the Bloc/repository contract and test it there.

## Local verification checklist

- [ ] Baseline and after measurement use the same profile-mode scenario.
- [ ] Event, handler, repository, rebuild, frame, and memory signals are not conflated.
- [ ] A reduced rebuild count still renders every meaningful state field.
- [ ] A reduced request count still preserves required events and ordering.
- [ ] No stream, timer, repository client, or Bloc remains retained after the owner closes.
- [ ] Logs avoid secrets, unbounded payloads, and high-frequency noise.
- [ ] Any local recommendation is labeled as such in review notes.
- [ ] The final report states device/mode limitations and unresolved trade-offs.

## Sources and boundaries

- [Flutter Bloc concepts](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/flutter-bloc-concepts.mdx) — observer and integration concepts.
- `packages/bloc/lib/src/bloc.dart` — event, transition, and handler lifecycle hooks.
- `packages/bloc/lib/src/bloc_base.dart` — change/error/close behavior and equal-state suppression.
- `examples/bloc_concurrency_visualizer` — useful visualization ideas, not a benchmark.
- Flutter DevTools/profile-mode workflow — local engineering recommendation for this skill; no upstream Bloc performance chapter is claimed.
