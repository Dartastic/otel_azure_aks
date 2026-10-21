// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_aks/otel_azure_aks.dart';

/// Traces Azure Aks calls with OpenTelemetry.
///
/// `otel_azure_aks` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure Aks call in
/// [tracedAzureAKS]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-aks-example');

  // Traces a Azure Aks call.
  final azureAKSId = await tracedAzureAKS<String>(
    operation: 'create',
    invoke: () async {
      // Make the Azure Aks call here, then report what it returned.
      const id = 'azure_aks_8f3a2c';
      return const AzureAKSCallResult(
          value: id,
          result: AzureAKSResult(
              subscriptionId: 'subscription_8f3a2c',
              resourceGroup: 'Order',
              clusterName: 'example',
              version: '1',
              nodePool: 'example',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAzureAKS create returned $azureAKSId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureAKSInstrumentationAsync.
  await runWithoutAzureAKSInstrumentationAsync(
    () => tracedAzureAKS<String>(
      operation: 'create',
      invoke: () async {
        const id = 'azure_aks_8f3a2c';
        return const AzureAKSCallResult(
            value: id,
            result: AzureAKSResult(
                subscriptionId: 'subscription_8f3a2c',
                resourceGroup: 'Order',
                clusterName: 'example',
                version: '1',
                nodePool: 'example',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
