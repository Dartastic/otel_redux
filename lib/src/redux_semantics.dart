// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Attribute keys emitted by `otel_redux`.
///
/// The OpenTelemetry semantic-conventions registry has no convention
/// for client-side state management yet, so these `state.*` keys are
/// vendor-neutral placeholders. When a registry convention lands,
/// these can `@Deprecated`-pivot to the API's enum.
enum ReduxSemantics implements OTelSemantic {
  /// The state-management system. Always [stateSystemRedux].
  stateSystem('state.system'),

  /// The state operation. Always [stateOperationDispatch] for the
  /// middleware's per-action spans.
  stateOperation('state.operation'),

  /// Runtime type name of the dispatched action.
  stateActionName('state.action.name');

  const ReduxSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}

/// Value of [ReduxSemantics.stateSystem] for Redux stores.
const String stateSystemRedux = 'redux';

/// Value of [ReduxSemantics.stateOperation] for a store dispatch.
const String stateOperationDispatch = 'dispatch';
