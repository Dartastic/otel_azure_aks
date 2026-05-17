# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedAzureAKS<T>(...)` — wraps a otel_azure_aks call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutAzureAKSInstrumentation()` / `Async()`.
