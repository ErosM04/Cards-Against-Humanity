# Concurrency and streams

Performance work at the event boundary is a correctness decision first. Start by naming the event's ordering, lossiness, cancellation, and side-effect contract; then choose the smallest transformer that satisfies it.

## Transformer matrix

| Policy | Direct upstream semantics | Fit | Failure mode to verify |
| --- | --- | --- | --- |
| `concurrent()` | Matching handlers run concurrently; completion order may differ from add order. This is Bloc's default. | Independent reads or commutative work. | Stale completion overwrites newer data; side effects race. |
| `sequential()` | Matching events queue and run one at a time. | Ordered writes, serialized append, mutation commands. | Burst creates backlog and latency. |
| `droppable()` | A matching event arriving while one is active is ignored. | Idempotent load, submit, or pagination trigger. | A meaningful event is intentionally lost. |
| `restartable()` | A new matching event cancels the previous handler subscription and runs the latest. | Search/typeahead, latest filter, replaceable refresh. | Underlying side effects may not be undoable; stale external work may continue. |

**Direct upstream facts:** Bloc processes events concurrently by default. `Bloc.transformer` is a static global default applied to each handler unless that `on<Event>` supplies its own transformer; a per-handler override only controls matching events. The standard transformer definitions and semantics are in `packages/bloc/lib/src/bloc.dart` and `packages/bloc_concurrency/README.md`.

**Local engineering recommendation:** custom debounce/throttle transformers are appropriate only when their delay, cancellation, event loss, and test strategy are written down next to the registration. A transformer cannot make a non-transactional repository write safe.

```dart
on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
on<SavePressed>(_onSavePressed, transformer: sequential());
on<LoadNextPage>(_onLoadNextPage, transformer: droppable());
```

If two different event types update one resource, per-handler transformers do not automatically coordinate them. Use a repository operation, explicit state guard, or a single event policy that preserves the resource invariant.

## Await stream adapters

`Emitter.onEach` and `Emitter.forEach` subscribe to a stream and map stream values/errors into emitted states. Their returned futures must be awaited by the handler. The emitter tracks completion with `isDone`; a completed or canceled handler must not emit more states.

```dart
class TickerBloc extends Bloc<TickerStarted, TickerState> {
  TickerBloc(this._ticks) : super(const TickerState.initial()) {
    on<TickerStarted>(_onStarted, transformer: restartable());
  }

  final Stream<int> Function() _ticks;

  Future<void> _onStarted(
    TickerStarted event,
    Emitter<TickerState> emit,
  ) async {
    await emit.onEach<int>(
      _ticks(),
      onData: (value) => emit(TickerState.running(value)),
      onError: (error, stackTrace) {
        if (emit.isDone) return;
        addError(error, stackTrace);
        emit(TickerState.failure(error));
      },
    );
  }
}
```

Use `emit.forEach` when a value-to-state function is enough. Prefer `onEach` when error mapping or multiple emissions require explicit handling. Awaiting makes handler completion visible to transformers and teardown; an unawaited subscription can outlive a restart, emit after close, or retain resources.

**Direct upstream facts:** `packages/bloc/lib/src/emitter.dart` exposes `onEach`, `forEach`, `isDone`, and completion behavior; `examples/flutter_bloc_with_stream` demonstrates an awaited stream-backed ticker with restartable behavior.

## Cancellation and errors

- Define whether cancellation is cooperative (the repository cancels an HTTP/stream operation) or only suppresses state delivery.
- Check `emit.isDone` before delayed or callback-driven emissions when the operation cannot be fully canceled.
- Preserve error and stack context with `addError(error, stackTrace)` when mapping a failure state.
- Close stream subscriptions and injected resources through the owner; do not make a widget own a repository subscription just to save a rebuild.
- Treat `restartable()` as latest-state delivery, not proof that an external request was canceled on the wire.

## Anti-patterns

- Assuming `add(A); add(B)` means A completes before B.
- Adding `sequential()` to every handler without checking whether overlap is safe or whether the queue can grow.
- Using `droppable()` for a write or user action that must not be lost.
- Using `restartable()` around non-idempotent writes or side effects without a compensation/idempotency policy.
- Calling `emit.onEach`/`emit.forEach` without `await` or ignoring stream errors.
- Starting a raw `listen` inside a handler and forgetting the subscription on restart/close.
- Applying a transformer to one event type while assuming it serializes a different event type.
- Using a timer as a hidden debounce without testing cancellation and handler completion.

## Verification checklist

- [ ] Event ordering and overlap are stated in domain terms.
- [ ] Transformer scope matches every event type that can update the resource.
- [ ] Burst behavior, dropped events, latest-only behavior, and queue growth are covered.
- [ ] Stream adapters are awaited; errors map intentionally; completion and close release work.
- [ ] No late callback emits after cancellation or close.
- [ ] External side effects have idempotency or compensation when superseded.
- [ ] A controlled fake proves the intended event-to-state sequence without arbitrary sleeps.

## Sources

- `packages/bloc/lib/src/bloc.dart` — event dispatch and transformer scope.
- `packages/bloc/lib/src/emitter.dart` — awaited stream adapters, completion, and `isDone`.
- `packages/bloc_concurrency/README.md` — standard transformer semantics.
- `examples/flutter_bloc_with_stream` — stream-backed ticker pattern.
- `examples/bloc_concurrency_visualizer` — visual transformer comparison and timeline ideas.
