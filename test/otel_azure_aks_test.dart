// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_azure_aks/otel_azure_aks.dart';
import 'package:test/test.dart';

void main() {
  group('otel_azure_aks', () {
    test('suppression toggles in zone', () async {
      expect(azureAKSInstrumentationSuppressed(), isFalse);
      await runWithoutAzureAKSInstrumentationAsync(() async {
        expect(azureAKSInstrumentationSuppressed(), isTrue);
      });
      expect(azureAKSInstrumentationSuppressed(), isFalse);
    });

    test('AzureAKSResult fields default null', () {
      const r = AzureAKSResult();
      expect(r.statusCode, isNull);
    });
  });
}
