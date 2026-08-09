# Changelog

## [0.2.0] - 2026-08-10

### Added

- `ReduxSemantics` enum (`state.system`, `state.operation`,
  `state.action.name`) plus `stateSystemRedux` /
  `stateOperationDispatch` value constants; the middleware and tests
  now use these instead of raw string keys. Emitted keys unchanged.
- Runnable example (`example/otel_redux_example.dart`).
- Dartdoc for the zone-scoped suppression API.

## [0.1.0-beta.1] - 2026-05-16

### Added

- `otelReduxMiddleware<S>({tracer})` — a [Middleware] that opens
  an INTERNAL span around each dispatched action with
  `state.system=redux`, `state.operation=dispatch`,
  `state.action.name=<runtime type>`.
- Zone-scoped suppression
  (`runWithoutReduxInstrumentation` / async variant).
- 3 tests using real `Store<int>` instances.
