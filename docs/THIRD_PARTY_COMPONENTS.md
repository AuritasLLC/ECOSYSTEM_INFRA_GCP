# Third-party components in the ASM+ Marketplace package

This inventory supports, but does not replace, Auritas legal, security, and
open-source compliance review.

## Kubernetes Application CRD

- Source: `GoogleCloudPlatform/marketplace-k8s-app-tools`
- Source commit checked: `2d615d22da681c5ced60c79be34b7ce78297dcfa`
- Source path: `crd/app-crd.yaml`
- License header: Apache-2.0
- Local path: `helm/ecosystem/crds/application-crd.yaml`
- Normalized source equality verified on 2026-08-14; line-ending differences
  account for the raw file hash difference.

## Cloud SQL Auth Proxy

- Source: `gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.14.1`
- Linux x86-64 manifest:
  `sha256:e9ad52f6dd580693bea8b2df270e8cc762114706b60d3166ab599e50afd6f0e4`
- Source project license: Apache-2.0
- Final Marketplace image must be mirrored, scanned, annotated with the
  product service name, and tagged `1.0` and `1.0.0`.

## PostgreSQL

- Source: Docker Official Image `postgres:16`
- Version observed on 2026-08-14: PostgreSQL `16.15`
- Linux x86-64 manifest:
  `sha256:56f243d2355bad7d2016b1e78b80da8ac9e7967b766be2bfbff84fe85ffa30bc`
- Upstream PostgreSQL license plus licenses of the Debian base and included
  packages apply; verify the image SBOM and notices during release review.
- Final Marketplace image must be mirrored, scanned, annotated with the
  product service name, and tagged `1.0` and `1.0.0`.

Do not replace these digest-pinned inputs with mutable source tags during a
release. Any source change requires a new inventory entry and another security
and legal review.
