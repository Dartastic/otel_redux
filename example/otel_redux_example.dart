// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_redux/otel_redux.dart';
import 'package:redux/redux.dart';

class IncrementAction {}

class ResetAction {}

int counterReducer(int state, dynamic action) {
  if (action is IncrementAction) return state + 1;
  if (action is ResetAction) return 0;
  return state;
}

Future<void> main() async {
  // 1. Bring up OTel before creating the store so trace context is
  //    flowing when the first action is dispatched.
  await OTel.initialize(serviceName: 'redux-example');

  // 2. Add the middleware to your store as usual.
  final store = Store<int>(
    counterReducer,
    initialState: 0,
    middleware: [otelReduxMiddleware<int>()],
  );

  // Each dispatch emits an INTERNAL span:
  //   name: `redux IncrementAction`
  //   attributes: state.system=redux, state.operation=dispatch,
  //               state.action.name=IncrementAction
  store.dispatch(IncrementAction());
  store.dispatch(IncrementAction());

  // Suppression: no span for this dispatch.
  runWithoutReduxInstrumentation(() {
    store.dispatch(ResetAction());
  });

  await OTel.shutdown();
}
