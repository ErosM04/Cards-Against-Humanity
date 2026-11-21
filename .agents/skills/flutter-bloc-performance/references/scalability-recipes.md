# Scalability recipes

These recipes adapt upstream tutorials/examples into reviewable Bloc boundaries. The Dart files under `assets/` are compact templates; replace project-specific models, repositories, and state value types before use.

## Infinite list

**Direct upstream fact:** the Flutter infinite-list tutorial/example batches posts, stops when a reached-max condition is known, throttles the scroll-triggered fetch, drops a trigger while a fetch is active, and renders with `ListView.builder`.

Keep the page invariant in the Bloc/repository:

1. Store immutable accumulated items and a `hasReachedMax` (or equivalent) marker in state.
2. Ignore `fetch` when the marker is true or when a request is already active.
3. Request a bounded batch from the repository; append a new list rather than mutating the old one.
4. Mark the end from the repository response, not from a guessed item count.
5. Trigger from scroll position in the view, but keep fetch policy and mapping in the Bloc.
6. Use a throttled + droppable transformer for noisy scroll events only when the repository operation is safe to drop while active.

`assets/infinite-list/post_bloc.dart` and `assets/infinite-list/posts_list.dart` show the separation. Their `Post` and `PostRepository` types are templates and intentionally project-specific.

### Pagination anti-patterns

- Fetching on every scroll notification with no throttle, in-flight guard, or end marker.
- Replacing the accumulated list with the latest page.
- Mutating `state.posts.addAll(...)`, which breaks immutability and equality assumptions.
- Making the view calculate page offsets or call transport directly.
- Treating a short page as proof of the end when the API contract does not guarantee it.
- Using `sequential()` without a bounded event source, creating duplicate queued pages.

## Debounced search and cache

**Direct upstream fact:** the GitHub search tutorial/example debounces query input, uses latest-only `switchMap`, and routes access through a repository cache.

A robust typeahead pipeline is:

```text
raw query -> trim/validate -> debounce -> latest-only request -> repository cache -> state
```

- Treat blank or too-short input as an explicit idle/empty state.
- Debounce high-frequency input before network work.
- Use `restartable()` or an equivalent latest-only stream operator so an old response cannot replace a newer query's result.
- Keep cache lookup, TTL/invalidation, pagination of results, and transport mapping in the repository.
- Include the normalized query in the result state so a stale response can be rejected defensively.
- Decide whether cached data is shown immediately, while refreshing, or only after a network miss.

`assets/debounced-search/github_search_bloc.dart` is a template; its `GithubRepository`, `GithubSearchResult`, and state equality must be adapted.

### Search anti-patterns

- Debouncing in the widget and again in the Bloc with two unowned timers.
- Keeping a mutable cache map in a Bloc without invalidation or size policy.
- Letting concurrent responses race and trusting completion order.
- Treating cancellation as undoing a request that already reached the server.
- Returning results without a query key, making stale-result diagnosis impossible.

## Repository boundary

**Direct upstream fact:** architecture guidance keeps repository/data-provider work below the Bloc and discourages direct Bloc-to-Bloc coupling. The Bloc coordinates event/state policy; the repository owns transport, mapping, batching, cache, retry, and cancellation capabilities.

**Local engineering recommendation:** expose an operation-shaped repository API (`fetchPage`, `search`, `watch`, `cancel`) rather than passing a client into a widget. Keep performance policy near the boundary that owns the work, but make user-visible state transitions in the Bloc. Coordinate sibling Blocs in presentation or through a shared domain/repository stream, not by reaching into each other's state.

## Verification checklist

- [ ] The view only emits intent and renders state; no transport or cache code is in `build`.
- [ ] Page accumulation, reached-max, duplicate triggers, and errors are deterministic.
- [ ] Search normalization, debounce, latest-only behavior, cache hits/misses, and stale-result rejection are explicit.
- [ ] Repository ownership includes cache lifetime, invalidation, request cancellation, and mapping.
- [ ] State collections are immutable and equality-aware.
- [ ] Repeated events do not create unbounded requests or memory retention.
- [ ] Templates are adapted to real project types before being treated as implementation.

## Sources

- [Infinite list tutorial](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/tutorials/flutter-infinite-list.mdx)
- `examples/flutter_infinite_list` — throttled/droppable pagination and `ListView.builder`.
- [GitHub search tutorial](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/tutorials/github-search.mdx)
- `examples/github_search` — debounce, latest-only search, cache, and repository.
- [Architecture](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/architecture.mdx)
- `examples/bloc_concurrency_visualizer` — transformer behavior visualization.
