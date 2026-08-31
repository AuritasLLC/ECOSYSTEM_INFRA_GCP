# ASM+ Helm deployer source

This directory builds the pre-submission ASM+ Standard Kubernetes deployer.
The deployer uses Google's Helm deployer base, embeds `chart/ecosystem`, and
exposes all ten runtime images through `schema.yaml`.

Published candidate:

```text
us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0
sha256:62fa44cd72deaab884c9fe42546821861a2c7a5dddfe722d5946507b31e89983
```

The `1.0` tag resolves to the same digest. Producer Portal completed schema
extraction, test deployment, functional verification, cleanup, and its
vulnerability gate successfully on 31 August 2026.

Build and publish a single `linux/amd64` manifest. Producer Portal reads
`/data/schema.yaml` from the deployer image and must not be given a multi-image
OCI index with separate provenance or SBOM attestations.

```powershell
docker buildx build `
  --platform linux/amd64 `
  --provenance=false `
  --sbom=false `
  --output "type=registry,oci-mediatypes=true" `
  --annotation "manifest:com.googleapis.cloudmarketplace.product.service.name=services/asm-plus.endpoints.auritas-asmplus-public.cloud.goog" `
  --tag us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0 `
  --tag us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0 `
  marketplace/deployer
```

Validate the embedded Marketplace schema:

```powershell
docker run --rm --entrypoint /bin/validate_schema.py `
  us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0
```

The image includes `/data-test/schema.yaml` plus a Helm test overlay. Google
Marketplace Verification deploys one real ASM+ frontend and executes an
in-cluster HTTP health check without requiring customer infrastructure.

Before submitting the release for Google review, complete the BYOL license
contract and the internal open-source license decision.
