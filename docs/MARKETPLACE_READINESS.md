# Standard Kubernetes BYOL readiness register

This register separates completed migration work from release blockers. The
repository must not be represented as a validated Marketplace package while a
required item remains open.

## Confirmed

- Google Cloud Marketplace Support instructed Auritas to create a new Standard
  Kubernetes product because the Terraform Kubernetes product cannot be
  converted.
- Auritas resubmitted Solution Validation for Standard Kubernetes with BYOL.
- The public repository now describes Standard Kubernetes and BYOL as the
  current delivery model.
- The former Terraform Kubernetes module is retained under
  `legacy/terraform-kubernetes/` and is no longer the primary deployment path.
- The existing Helm chart includes the required `Application` custom resource
  and supports an x86-based GKE deployment.
- Application images are already staged in the producer project's Artifact
  Registry; new Standard Kubernetes releases must use the new product's service
  name annotation and release identifiers.
- Producer Portal shows the active product as `Kubernetes App`, with product ID
  `asm-plus` and service name
  `asm-plus.endpoints.auritas-asmplus-public.cloud.goog`.
- The Helm deployer schema declares all ten runtime images, the chart no longer
  creates Kubernetes service accounts, and the unnecessary packaged
  `Application` CRD was removed.
- Candidate deployer `1.0.0` and track tag `1.0` are published at
  `us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/deployer`.
  Both resolve to digest
  `sha256:62fa44cd72deaab884c9fe42546821861a2c7a5dddfe722d5946507b31e89983`.
- The deployer is a single `linux/amd64` OCI manifest with the required
  Marketplace service-name annotation. It includes `/data-test`, a real ASM+
  frontend, a Tester Pod, and an unconditional `Application` resource.
- Producer Portal completed schema extraction, test deployment, functional
  verification, cleanup, and its vulnerability gate successfully for that
  digest on 31 August 2026.

## Remaining governance and production-hardening items

- Confirm with the Google partner engineer that the schema `partnerId` value is
  `auritas`; Producer Portal does not display this identifier in its product UI.
- Choose and approve the repository's open-source `LICENSE` file. Google
  requires a public app repository to contain one; this is a legal decision and
  has not been made in this repository.
- Approve the public EULA URL and BYOL license-acquisition URL.
- Define the ASM+ license Secret format and implement application-side license
  validation, renewal, and error handling.
- Confirm the production and verification database profile: customer-managed
  Cloud SQL versus the chart's optional in-cluster PostgreSQL subchart.
- Prefix every namespaced Kubernetes resource with the customer-selected
  application name. The imported chart still contains fixed resource names and
  therefore cannot safely install two ASM+ instances in one namespace.
- Add a customer-safe Secret creation/reference design without plaintext values
  in source control or Helm release history.

## Required before submission

- Render and test every supported configuration; the customer production
  profile currently passes `helm lint` and `helm template`.
- Verify all Pods run as the expected non-root user where supported and that
  image references resolve to immutable digests.
- Complete legal review of third-party licenses and notices.
- Replace the pre-publication Marketplace URL notice in `docs/USER_GUIDE.md`
  with the published listing link.
- Review the complete UI deployment form and customer documentation.
- Submit pricing, product details, and container images only after the new
  Solution Validation and BYOL pricing are approved.

## Superseded Terraform product

Do not delete the existing Terraform Kubernetes product or its release
artifacts until Google confirms the appropriate retirement procedure. It is not
the basis for the new Standard Kubernetes BYOL submission.
