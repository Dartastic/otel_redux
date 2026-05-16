// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_redux/otel_redux.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

class IncrementAction {}

class DecrementAction {}

int counterReducer(int state, dynamic action) {
  if (action is IncrementAction) return state + 1;
  if (action is DecrementAction) return state - 1;
  return state;
}

void main() {
  group('otelReduxMiddleware', () {
    late _MemorySpanExporter exporter;
    late Store<int> store;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'redux-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
      store = Store<int>(
        counterReducer,
        initialState: 0,
        middleware: [otelReduxMiddleware<int>()],
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('dispatch emits an INTERNAL span per action', () {
      store.dispatch(IncrementAction());
      store.dispatch(IncrementAction());
      store.dispatch(DecrementAction());

      expect(store.state, equals(1));
      expect(exporter.spans, hasLength(3));

      final names = exporter.spans.map((s) => s.name).toList();
      expect(
          names,
          equals([
            'redux IncrementAction',
            'redux IncrementAction',
            'redux DecrementAction',
          ]));

      final attrs = _attrs(exporter.spans.first);
      expect(attrs['state.system'], equals('redux'));
      expect(attrs['state.operation'], equals('dispatch'));
      expect(attrs['state.action.name'], equals('IncrementAction'));
      expect(exporter.spans.first.kind, equals(SpanKind.internal));
    });

    test('reducer exception flips span to Error and propagates', () {
      final broken = Store<int>(
        (int state, dynamic action) =>
            action is _BoomAction ? throw StateError('boom') : state,
        initialState: 0,
        middleware: [otelReduxMiddleware<int>()],
      );

      expect(
        () => broken.dispatch(_BoomAction()),
        throwsStateError,
      );

      final span = exporter.spans.firstWhere(
        (s) => s.name == 'redux _BoomAction',
      );
      expect(span.status, equals(SpanStatusCode.Error));
      expect(_attrs(span)['error.type'], equals('StateError'));
    });

    test('runWithoutReduxInstrumentation bypasses span creation', () {
      runWithoutReduxInstrumentation(() {
        store.dispatch(IncrementAction());
      });
      expect(store.state, equals(1));
      expect(exporter.spans, isEmpty);
    });
  });
}

class _BoomAction {}
