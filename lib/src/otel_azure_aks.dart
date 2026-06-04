// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_azure_aks_suppression.dart';

class AzureAKSResult {
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

class AzureAKSCallResult<T> {
  const AzureAKSCallResult({required this.value, this.result});
  final T value;
  final AzureAKSResult? result;
}

Future<T> tracedAzureAKS<T>({
  required String operation,
  required Future<AzureAKSCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (azureAKSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_azure_aks');
  final span = t.startSpan('aks $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('azure.service', 'aks')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.subscription.id', res.subscriptionId!)
        ]));
      }
      if (res.resourceGroup != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.resource_group', res.resourceGroup!)
        ]));
      }
      if (res.clusterName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('k8s.cluster.name', res.clusterName!)]));
      }
      if (res.version != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('k8s.cluster.version', res.version!)]));
      }
      if (res.nodePool != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('azure.aks.node_pool', res.nodePool!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('aks.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
