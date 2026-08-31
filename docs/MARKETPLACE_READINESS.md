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
  `sha256:35024f26ab919514acc5fec65f757cad49662faa6c786bd124e95272e2cb07ca`.
- Artifact Analysis completed for that digest with zero critical and zero high
  severity findings. The Google deployer tools were rebuilt with Go 1.26.6 and
  Helm's ORAS dependency was updated to 2.6.2 to remove the fixable findings in
  the pinned official base.

## Required before linking the deployer in Producer Portal

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
- Define how Marketplace Verification receives a working Cloud Storage bucket
  and a Workload Identity-enabled Kubernetes service account. ASM Storage API
  does not have a local filesystem storage backend.
- Prefix every namespaced Kubernetes resource with the customer-selected
  application name. The imported chart still contains fixed resource names and
  therefore cannot safely install two ASM+ instances in one namespace.
- Add a customer-safe Secret creation/reference design without plaintext values
  in source control or Helm release history.

## Required before submission

- Add a functional Tester Pod and `/data-test/schema.yaml`.
- Render and test every supported configuration; the customer production
  profile currently passes `helm lint` and `helm template`.
- Build and scan every application image and the deployer image.
- Run local Marketplace verification with `mpdev verify`, proving installation,
  functional tests, and uninstallation.
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
