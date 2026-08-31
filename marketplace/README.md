# Standard Kubernetes Marketplace package

This directory is the source area for the ASM+ Standard Kubernetes deployer.
It is intentionally marked pre-release while the new Product ID, service name,
BYOL contract, and verification prerequisites are being finalized.

The final package must contain:

- A Helm-based deployer image with `/data/schema.yaml`.
- The ASM+ chart and `Application` resource.
- Parameterized references for every application image.
- A BYOL license input and application-side validation workflow.
- A verification overlay and Tester Pod.
- Evidence that installation, functionality testing, and uninstallation pass.

See [the readiness register](../docs/MARKETPLACE_READINESS.md) before building
or publishing this package.
