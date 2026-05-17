# otel_azure_aks

Dartastic OpenTelemetry bridge for Azure AKS (managed Kubernetes).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_azure_aks/otel_azure_aks.dart';

await tracedAzureAKS<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AzureAKSCallResult(value: r, result: AzureAKSResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAzureAKSInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
