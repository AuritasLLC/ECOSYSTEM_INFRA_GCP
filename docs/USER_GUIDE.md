# ASM+ on Google Cloud: Deployment and User Guide

This guide covers the Google Cloud Marketplace deployment and operation of
**Auritas Storage Manager (ASM+)**.

- Product: [Auritas Storage Manager (ASM+)](https://console.cloud.google.com/marketplace/product/auritas-asmplus-public/asm-plus)
- Publisher: Auritas LLC
- Support: [Auritas contact page](https://www.auritas.com/contact-us/) or
  `connect@auritas.com`

## 1. Overview

ASM+ is an enterprise document-management application for SAP environments.
It centralizes document storage and access and provides administration,
search, and document-viewing web interfaces. ASM Storage API is the central
application API. Optional integration workloads connect ASM+ to SAP Business
and SAP SuccessFactors using customer-approved credentials.

The Marketplace package runs in the customer's Google Cloud project. It uses
Terraform through Infrastructure Manager and Helm to create:

- A dedicated VPC and VPC-native, x86-based GKE cluster.
- A Cloud SQL for PostgreSQL instance reachable through private IP.
- A private Cloud Storage data bucket with versioning, public-access
  prevention, and a seven-day soft-delete policy.
- Secret Manager secrets and Workload Identity bindings.
- A global HTTPS ingress, reserved IP address, and Google-managed TLS
  certificate.
- ASM+ application workloads and database migrations.

The customer controls the project, infrastructure, data, networking, secrets,
backups, scaling, and Google Cloud resource costs. Product pricing and licence
terms are shown on the Marketplace listing.

## 2. Before you deploy

Prepare the following:

1. A billing-enabled Google Cloud project for the customer deployment.
2. A deployment service account authorized to enable required APIs and manage
   Compute Engine networking, GKE, Cloud SQL, Cloud Storage, Secret Manager,
   IAM service accounts and project IAM bindings. Cloud DNS permissions are
   also required when ASM+ manages DNS records.
3. Available regional quota for GKE nodes and CPUs, persistent disks, external
   IP addresses, private service networking, and Cloud SQL.
4. A delegated DNS suffix, such as `asmplus.example.com`, for the ASM+
   endpoints.
5. The initial ASM+ administrator email address.
6. An existing Cloud DNS managed zone only when Terraform will create DNS
   records.
7. Customer-approved SAP Business and SAP SuccessFactors configuration JSON
   only when the optional integrations are enabled.

Use least-privilege roles approved by the customer's cloud administrator. Do
not place passwords, tokens, private keys, or production connector JSON on a
command line or in source control.

The default location is `us-east1` / `us-east1-b`, the default GKE node type is
`e2-standard-4`, and the default Cloud SQL configuration is zonal. Review the
estimated infrastructure cost and the customer's availability requirements
before deployment.

The release images target `linux/amd64`. Select an x86 machine family; ARM
machine types such as T2A or Axion are not supported by this release.

## 3. Deployment inputs

### Required and primary inputs

| Input | Default | Description |
|---|---|---|
| `project_id` | Supplied by Marketplace | Customer project receiving the deployment. |
| `region` | `us-east1` | Region for regional resources. |
| `zone` | `us-east1-b` | Zone for the GKE cluster; it must belong to `region`. |
| `domain_suffix` | None | DNS suffix for the ASM+ endpoints. |
| `admin_email` | None | Initial ASM+ superadministrator email. |
| `node_machine_type` | `e2-standard-4` | x86 GKE node machine type. |
| `min_nodes` | `1` | Minimum GKE node count. |
| `max_nodes` | `4` | Maximum GKE node count. |
| `cloudsql_tier` | `db-custom-2-7680` | Cloud SQL compute tier. |
| `cloudsql_availability_type` | `ZONAL` | Use `REGIONAL` when high availability is required. |
| `manage_dns_records` | `false` | Create A records in an existing Cloud DNS zone. |
| `dns_managed_zone_name` | None | Required only when `manage_dns_records=true`. |
| `enable_sap_business_api` | `false` | Enable the optional SAP Business API. |
| `enable_successfactors_api` | `false` | Enable the optional SAP SuccessFactors API. |

### Advanced inputs

| Input | Default | Description |
|---|---|---|
| `network_name` | `asmplus-vpc` | Dedicated VPC name. |
| `subnetwork_name` | `asmplus-gke-subnet` | GKE subnet name. |
| `subnetwork_cidr` | `10.20.0.0/20` | Primary GKE node CIDR. |
| `pods_cidr` | `10.24.0.0/14` | Secondary Pod CIDR. |
| `services_cidr` | `10.28.0.0/20` | Secondary Service CIDR. |
| `private_services_prefix_length` | `16` | Prefix reserved for private service access. |
| `cluster_name` | `asmplus-gke` | GKE cluster name. |
| `node_pool_name` | `asmplus-pool` | GKE node-pool name. |
| `node_disk_size_gb` | `100` | Boot disk size per GKE node. |
| `namespace` | `asm-plus` | Kubernetes namespace. |
| `helm_release_name` | `asm-plus` | Helm release name. |
| `helm_timeout_seconds` | `1800` | Helm migration and installation timeout. |
| `gcs_bucket_name` | Derived from project ID | Globally unique ASM+ data bucket name. |
| `gcs_force_destroy` | `false` | Permit deletion of a non-empty data bucket. Keep false for data protection. |
| `cloudsql_instance_name` | `asmplus-postgres` | Cloud SQL instance name. |
| `cloudsql_database` | `auritasdemo` | ASM+ database name. |
| `cloudsql_user` | `auritas` | ASM+ database user. |
| `cloudsql_disk_size_gb` | `20` | Initial Cloud SQL SSD size; automatic growth is enabled. |
| `sap_basic_auth_users_json` | `{}` | Advanced SAP Business API credential JSON; a supplied value is retained in Terraform state. |
| `sf_managed_users_json` | `{}` | Advanced SAP SuccessFactors API credential JSON; a supplied value is retained in Terraform state. |

Network CIDRs must not overlap networks that need connectivity to ASM+.
Marketplace service labels, chart references, and image references are release
inputs managed by Google Cloud Marketplace and must not be overridden by the
customer.

Leave both connector JSON inputs at `{}` during Marketplace deployment whenever
possible. Configure customer-approved connector credentials after deployment
through the documented Secret Manager workflow with Auritas support. If either
input is supplied to Terraform, protect the Infrastructure Manager state as a
sensitive asset and never place the value in source control or command history.

## 4. Deploy from Google Cloud Marketplace

1. Open the [ASM+ Marketplace listing](https://console.cloud.google.com/marketplace/product/auritas-asmplus-public/asm-plus).
2. Select **Launch**, **Configure**, or the equivalent deployment action shown
   for the approved release.
3. Select the customer project and the approved deployment service account.
4. Enter the required location, DNS suffix, administrator, sizing, and optional
   integration values.
5. Review the deployment summary and estimated Google Cloud infrastructure
   charges.
6. Start the deployment and wait for Infrastructure Manager, database
   migrations, and the ASM+ Helm release to complete.

Do not use development tags or replace Marketplace-supplied image or chart
references. Use only a validated Marketplace release and the exact release
track and version shown on the listing.

## 5. Deploy from the command line

The Marketplace listing is the source of truth for the versioned Terraform
module URI. Copy the module URI displayed for the approved release; do not use
an internal staging object or an unversioned source.

Create a protected input file from
[`examples/asm-plus.tfvars.example`](../examples/asm-plus.tfvars.example), then
set the following shell variables:

```bash
export CUSTOMER_PROJECT_ID="your-customer-project"
export DEPLOYMENT_LOCATION="us-east1"
export DEPLOYMENT_SERVICE_ACCOUNT="projects/${CUSTOMER_PROJECT_ID}/serviceAccounts/asmplus-deployer@${CUSTOMER_PROJECT_ID}.iam.gserviceaccount.com"
export MARKETPLACE_MODULE_GCS_URI="copy-the-versioned-module-uri-from-the-approved-marketplace-release"
```

Apply the deployment:

```bash
gcloud infra-manager deployments apply asm-plus \
  --project="${CUSTOMER_PROJECT_ID}" \
  --location="${DEPLOYMENT_LOCATION}" \
  --service-account="${DEPLOYMENT_SERVICE_ACCOUNT}" \
  --gcs-source="${MARKETPLACE_MODULE_GCS_URI}" \
  --inputs-file="asm-plus.tfvars"
```

Keep the input file in an approved secrets location and delete unneeded local
copies after deployment. Never commit populated connector JSON.

## 6. One-time Helm and Application CRD setup

Infrastructure Manager deployments launched through Marketplace install the
published chart and its `Application` CRD automatically. Verify it after the
first deployment:

```bash
kubectl get crd applications.app.k8s.io
```

For an authorized manual Helm operation, authenticate to Artifact Registry and
pull the exact chart version shown in the Marketplace release:

```bash
gcloud auth print-access-token | helm registry login \
  -u oauth2accesstoken --password-stdin us-docker.pkg.dev

helm pull \
  oci://us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/ecosystem \
  --version "1.0.0" --untar

kubectl apply -f ecosystem/crds/application-crd.yaml
```

Do not install a chart from a mutable tag. Manual chart installation is for
approved support workflows; normal customer deployment uses the Marketplace
Terraform module.

## 7. Verify the deployment and obtain outputs

Get the latest Infrastructure Manager revision and its Terraform outputs:

```bash
export CUSTOMER_PROJECT_ID="your-customer-project"
export DEPLOYMENT_LOCATION="us-east1"

LATEST_REVISION="$(gcloud infra-manager deployments describe asm-plus \
  --project="${CUSTOMER_PROJECT_ID}" \
  --location="${DEPLOYMENT_LOCATION}" \
  --format='value(latestRevision)')"

gcloud infra-manager revisions describe "${LATEST_REVISION}" \
  --format='yaml(applyResults.outputs)'
```

Record the `gke_cluster_name`, `gke_cluster_location`, `namespace`,
`cloudsql_instance_name`, `gcs_bucket_name`, `ingress_ip`, `dns_records`, and
`application_urls` outputs. Connect to GKE using the values from the outputs:

```bash
gcloud container clusters get-credentials "GKE_CLUSTER_NAME" \
  --project="${CUSTOMER_PROJECT_ID}" \
  --zone="GKE_CLUSTER_LOCATION"

kubectl -n "ASMPLUS_NAMESPACE" get \
  applications.app.k8s.io,pods,services,ingress
```

All required Pods should become `Ready`, both Helm releases should be
deployed, and the `Application` resource should report the approved version.

Verify that each running container resolves to an immutable registry digest:

```bash
kubectl -n "ASMPLUS_NAMESPACE" get pods \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .status.containerStatuses[*]}{"  "}{.name}{": "}{.imageID}{"\n"}{end}{end}'
```

Every application image ID must include `@sha256:`. The Marketplace release
process pins each source image by digest while exposing the approved release
track and exact version. Do not override the Marketplace-managed image
repositories or tags. If an image is missing a digest or does not match the
approved release, stop validation and contact Auritas support.

## 8. DNS and TLS

When `manage_dns_records=false`, create each A record from the `dns_records`
output so that it resolves to `ingress_ip`. When it is true, confirm the records
in the selected Cloud DNS managed zone.

Google-managed TLS certificates become active only after public DNS resolves
to the ingress IP. Verify DNS, Ingress, and the certificate:

```bash
dig +short "app.asmplus.example.com"
kubectl -n "ASMPLUS_NAMESPACE" get ingress,managedcertificate
kubectl -n "ASMPLUS_NAMESPACE" describe managedcertificate asmplus-certificate
curl --fail --head "https://app.asmplus.example.com/"
```

Replace the example hostname with the deployed `domain_suffix`. Do not disable
HTTPS in production.

## 9. Initial access and basic usage

The initial administrator username is `admin`; the email is the `admin_email`
deployment input. Retrieve the generated password through an approved
privileged workflow:

```bash
gcloud secrets versions access latest \
  --project="${CUSTOMER_PROJECT_ID}" \
  --secret="auth-superadmin-password"
```

Open `https://auth.DOMAIN_SUFFIX`, sign in, and change the initial end-user
password according to the customer's identity policy. Then open
`https://app.DOMAIN_SUFFIX` and perform this smoke test:

1. Confirm that the Documents page loads without a backend error.
2. Upload a non-sensitive test document.
3. Search for the document and open it in the document viewer.
4. Delete the test document and verify the expected recycle-bin behavior.

Use only synthetic or approved test content. A simple availability check is:

```bash
curl --fail --silent --show-error "https://api-auth.DOMAIN_SUFFIX/health/db"
curl --fail --silent --show-error "https://api-asm-plus.DOMAIN_SUFFIX/health/ready"
curl --fail --silent --show-error --output /dev/null "https://app.DOMAIN_SUFFIX/"
curl --fail --silent --show-error --output /dev/null "https://viewer.DOMAIN_SUFFIX/"
```

Generated runtime values are stored in Secret Manager and in the Kubernetes
Secret `asmplus-runtime-secrets`. Sensitive values can also be present in
restricted Infrastructure Manager/Terraform state. Database, JWT, API-key, and
client-key rotation must be coordinated with Auritas support so every copy and
dependent workload remains consistent.

## 10. Back up and restore

Cloud SQL automatic backups, seven retained backups, and point-in-time recovery
are enabled. The data bucket uses object versioning and a seven-day soft-delete
policy. These controls do not replace the customer's backup policy.

Before an upgrade or destructive operation:

```bash
gcloud sql backups create \
  --project="${CUSTOMER_PROJECT_ID}" \
  --instance="CLOUDSQL_INSTANCE_NAME" \
  --description="ASM+ pre-change backup"

gcloud sql backups list \
  --project="${CUSTOMER_PROJECT_ID}" \
  --instance="CLOUDSQL_INSTANCE_NAME"

gcloud storage ls --all-versions "gs://ASMPLUS_DATA_BUCKET/**"
```

Copy critical objects to a separately governed backup bucket and protect the
runtime secrets according to the customer's approved secrets-backup process.
Record the Marketplace release, module URI, deployment inputs, and backup IDs.

For an in-place database restore, select a verified backup and use the Cloud
SQL restore workflow or `gcloud sql backups restore`. A restore to a replacement
instance, or a complete disaster recovery involving database, bucket, and
runtime secrets, requires a coordinated recovery plan and updated Terraform
configuration. Test the full procedure in a non-production project.

## 11. Updates and scaling

For an approved patch or minor release:

1. Test the new Marketplace release in a non-production project.
2. Back up Cloud SQL, Cloud Storage data, and required runtime secrets.
3. Copy the new versioned module URI from Marketplace.
4. Preserve the complete approved input file and change only intended values.
5. Run `gcloud infra-manager deployments apply` with the new module URI and the
   complete input file.
6. Repeat the deployment, TLS, login, upload, search, and viewer checks.

To scale GKE, update `min_nodes`, `max_nodes`, or `node_machine_type`. To scale
the database, update `cloudsql_tier`; use
`cloudsql_availability_type="REGIONAL"` when approved high availability is
required. Database changes can restart the instance, so preview and schedule
them.

Do not retag, replace, or directly edit images from an approved release.
Breaking changes and manual data migrations require a new release track and
release-specific instructions.

## 12. Delete ASM+

Deletion is destructive. First export or back up all required documents,
database data, and runtime secrets and verify that the backups are restorable.

The default `gcs_force_destroy=false` prevents Terraform from deleting a
non-empty data bucket. Retain or remove all object generations according to the
customer's retention policy before deleting the deployment, or use a separately
approved configuration change.

Delete the Infrastructure Manager deployment and its managed resources:

```bash
gcloud infra-manager deployments delete asm-plus \
  --project="${CUSTOMER_PROJECT_ID}" \
  --location="${DEPLOYMENT_LOCATION}" \
  --delete-policy=delete
```

After deletion, verify the project for residual or billable resources. Cloud
SQL retained backups, APIs left enabled by the module, customer-managed DNS
delegation, backup buckets, and resources outside the Terraform deployment can
remain. Secret Manager secrets managed by the deployment are deleted, so a
database-and-bucket-only backup is not a complete ASM+ recovery set.

## 13. Support information

For support, provide the Marketplace product and release, customer project ID,
Infrastructure Manager deployment ID and location, approximate failure time
and time zone, and sanitized Infrastructure Manager or Kubernetes errors.
Never send passwords, access tokens, secret payloads, private keys, Terraform
state, or unredacted customer documents.

Contact [Auritas](https://www.auritas.com/contact-us/) or email
`connect@auritas.com`.
