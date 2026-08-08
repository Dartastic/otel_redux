// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #otel_redux_suppress;

/// Whether Redux instrumentation is suppressed in the current [Zone].
///
/// True inside [runWithoutReduxInstrumentation] /
/// [runWithoutReduxInstrumentationAsync]; the middleware then
/// forwards actions without opening spans.
bool reduxInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

/// Runs [body] with Redux instrumentation suppressed: dispatches
/// inside it produce no spans.
T runWithoutReduxInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

/// Async variant of [runWithoutReduxInstrumentation]. Suppression
/// follows the zone, so awaited continuations stay suppressed.
Future<T> runWithoutReduxInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
