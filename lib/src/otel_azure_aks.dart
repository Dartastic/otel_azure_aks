// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_aks_suppression.dart';

class AzureAKSResult {
  /// Creates a result.
  const AzureAKSResult({
    this.subscriptionId,
    this.resourceGroup,
    this.clusterName,
    this.version,
    this.nodePool,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? subscriptionId;
  final String? resourceGroup;
  final String? clusterName;
  final String? version;
  final String? nodePool;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AzureAKSCallResult<T> {
  /// Creates a call result.
  const AzureAKSCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AzureAKSResult? result;
}

Future<T> tracedAzureAKS<T>({
  required String operation,
  required Future<AzureAKSCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (azureAKSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_azure_aks');
  final span = t.startSpan('aks $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('azure.service', 'aks')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.subscription.id', res.subscriptionId!)
        ]));
      }
      if (res.resourceGroup != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.resource_group', res.resourceGroup!)
        ]));
      }
      if (res.clusterName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('k8s.cluster.name', res.clusterName!)]));
      }
      if (res.version != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('k8s.cluster.version', res.version!)]));
      }
      if (res.nodePool != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.aks.node_pool', res.nodePool!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aks.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'aks.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
