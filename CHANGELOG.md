# Changelog

## [0.1.0-beta.1-wip]

### Added

- `otelReduxMiddleware<S>({tracer})` — a [Middleware] that opens
  an INTERNAL span around each dispatched action with
  `state.system=redux`, `state.operation=dispatch`,
  `state.action.name=<runtime type>`.
- Zone-scoped suppression
  (`runWithoutReduxInstrumentation` / async variant).
- 3 tests using real `Store<int>` instances.
