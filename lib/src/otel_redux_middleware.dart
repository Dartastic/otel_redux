// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:redux/redux.dart';

import 'redux_semantics.dart';
import 'redux_suppression.dart';

const _tracerName = 'otel_redux';

/// Returns a Redux [Middleware] that opens an INTERNAL span around
/// each dispatched action and forwards to the next dispatcher.
///
/// ```dart
/// final store = Store<AppState>(
///   appReducer,
///   initialState: AppState.initial(),
///   middleware: [otelReduxMiddleware<AppState>()],
/// );
/// ```
///
/// Span shape:
/// - name: `redux <action runtime type>`
/// - kind: INTERNAL
/// - attributes: `state.system=redux`, `state.operation=dispatch`,
///   `state.action.name=<runtime type>`
///
/// The span's duration covers the synchronous reducer run (Redux
/// dispatches are sync, even though async work can be triggered
/// inside thunk-like middleware). Exceptions in downstream
/// middleware flip the span to Error and propagate.
Middleware<S> otelReduxMiddleware<S>({Tracer? tracer}) {
  final t = tracer ?? OTel.tracerProvider().getTracer(_tracerName);
  return (Store<S> store, dynamic action, NextDispatcher next) {
    if (reduxInstrumentationSuppressed()) {
      next(action);
      return;
    }
    final actionName = action.runtimeType.toString();
    final span = t.startSpan(
      'redux $actionName',
      kind: SpanKind.internal,
      attributes: OTel.attributesFromMap(<String, Object>{
        ReduxSemantics.stateSystem.key: stateSystemRedux,
        ReduxSemantics.stateOperation.key: stateOperationDispatch,
        ReduxSemantics.stateActionName.key: actionName,
      }),
    );
    try {
      next(action);
    } catch (e, st) {
      span.addAttributes(OTel.attributes([
        OTel.attributeString(
          ErrorAttributes.errorType.key,
          e.runtimeType.toString(),
        ),
      ]));
      span.recordException(e, stackTrace: st);
      span.setStatus(SpanStatusCode.Error, e.toString());
      rethrow;
    } finally {
      span.end();
    }
  };
}
