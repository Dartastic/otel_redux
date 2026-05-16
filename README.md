# otel_redux

OpenTelemetry instrumentation for
[`package:redux`](https://pub.dev/packages/redux). Plug a
middleware into your store and every dispatch shows up in your
trace.

```dart
import 'package:redux/redux.dart';
import 'package:otel_redux/otel_redux.dart';

final store = Store<AppState>(
  appReducer,
  initialState: AppState.initial(),
  middleware: [otelReduxMiddleware<AppState>()],
);

store.dispatch(AddToCartAction(item: item));
// → span: `redux AddToCartAction`
```

Each dispatch opens an INTERNAL span with:
- name: `redux <action runtime type>`
- `state.system = redux`
- `state.operation = dispatch`
- `state.action.name = <runtime type>`

Spans inherit the surrounding active span as parent, so a
dispatch inside a `Tracer.startActiveSpan('user_flow', ...)`
nests naturally.

Suppression: `runWithoutReduxInstrumentation` and async variant.

## License

Apache 2.0
