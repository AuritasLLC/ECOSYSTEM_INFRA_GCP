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

## Required before building the deployer image

- Record the new Producer Portal product ID, solution ID, partner ID, and
  service name.
- Confirm the final image repository root and the release track/version.
- Add the new product service-name OCI annotation to every application image
  and the deployer image.
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
- Remove or replace chart resources that violate Standard Kubernetes deployer
  constraints, including any chart-created service account or unnecessary
  cluster-scoped resource.
- Prefix every namespaced Kubernetes resource with the customer-selected
  application name. The imported chart still contains fixed resource names and
  therefore cannot safely install two ASM+ instances in one namespace.
- Parameterize every image used by all charts and Jobs in `schema.yaml`.
- Add a customer-safe Secret creation/reference design without plaintext values
  in source control or Helm release history.
- Add the final Marketplace deployer `schema.yaml` and build the Helm deployer
  image under the required `deployer` image path.

## Required before submission

- Add a functional Tester Pod and `/data-test/schema.yaml`.
- Run `helm lint` and render all supported configurations.
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
