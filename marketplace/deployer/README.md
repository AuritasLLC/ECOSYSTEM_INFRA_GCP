# ASM+ Helm deployer source

This directory builds the pre-submission ASM+ Standard Kubernetes deployer.
The deployer uses Google's Helm deployer base, embeds `chart/ecosystem`, and
exposes all ten runtime images through `schema.yaml`.

Published candidate:

```text
us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0
sha256:35024f26ab919514acc5fec65f757cad49662faa6c786bd124e95272e2cb07ca
```

The `1.0` tag resolves to the same digest. Artifact Analysis completed with
zero critical and zero high-severity findings on 31 August 2026.

Build locally:

```powershell
docker build `
  --build-arg REGISTRY=us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace `
  --build-arg TAG=1.0.0 `
  --tag us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0 `
  marketplace/deployer
```

Validate the embedded Marketplace schema:

```powershell
docker run --rm --entrypoint /bin/validate_schema.py `
  us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer:1.0.0
```

This image is published for integration work, not yet for Google review. Before
submitting it in Producer Portal, complete the `data-test` overlay, Tester Pod,
BYOL license contract, open-source license decision, and local `mpdev verify`.
