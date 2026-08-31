# ASM+ Standard Kubernetes deployer 1.0.0

## Producer Portal identifiers

- Product type: Kubernetes App (Standard Kubernetes)
- Product ID / solution ID: `asm-plus`
- Service name: `asm-plus.endpoints.auritas-asmplus-public.cloud.goog`
- Producer project: `auritas-asmplus-public`
- Provisional schema partner ID: `auritas` (Google confirmation pending)

## Published artifact

```text
Repository: us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer
Tags:       1.0, 1.0.0
Digest:     sha256:62fa44cd72deaab884c9fe42546821861a2c7a5dddfe722d5946507b31e89983
Platform:   linux/amd64
```

## Verification completed

- Helm chart lint: passed.
- Customer production profile render: passed.
- Marketplace schema validation using `/bin/validate_schema.py`: passed.
- Verification profile render with the `Application` resource and Tester Pod:
  passed.
- Producer Portal schema extraction: passed.
- Producer Portal test deployment, functional test, cleanup, and vulnerability
  gate: passed.
- No chart-created Kubernetes `ServiceAccount`: confirmed.
- No packaged `CustomResourceDefinition`: confirmed.

## Security rebuild

The pinned official Google Helm deployer base contained `kubectl` 1.36.3 and
Helm 4.2.4 compiled with Go 1.26.5. They were rebuilt from their tagged source
with Go 1.26.6. Helm's `oras-go` dependency was updated from 2.6.1 to 2.6.2.

## Remaining release-governance items

Do not submit this candidate for Google review until the BYOL Solution
Validation is approved, the partner ID is confirmed, and the legal/license and
pricing decisions are complete. The technical Container images validation is
complete.
