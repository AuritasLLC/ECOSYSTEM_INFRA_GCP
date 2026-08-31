# Standard Kubernetes Marketplace package

This directory is the source area for the ASM+ Standard Kubernetes deployer.
Version `1.0.0` has been built and staged in the producer Artifact Registry,
but remains pre-submission while the BYOL and verification gates are completed.

The final package must contain:

- A Helm-based deployer image with `/data/schema.yaml`.
- The ASM+ chart and `Application` resource.
- Parameterized references for every application image.
- A completed BYOL license input and application-side validation workflow.
- A verification overlay and Tester Pod.
- Evidence that installation, functionality testing, and uninstallation pass.

See [the readiness register](../docs/MARKETPLACE_READINESS.md) before linking
the staged deployer to Producer Portal or submitting it for review.
