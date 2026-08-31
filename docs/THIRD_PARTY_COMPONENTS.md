# Third-party components in the ASM+ Marketplace package

This inventory supports, but does not replace, Auritas legal, security, and
open-source compliance review.

## Kubernetes Application CRD

- Source: `GoogleCloudPlatform/marketplace-k8s-app-tools`
- Source commit checked: `2d615d22da681c5ced60c79be34b7ce78297dcfa`
- Source path: `crd/app-crd.yaml`
- License header: Apache-2.0
- Local path: `marketplace/deployer/chart/ecosystem/crds/application-crd.yaml`
- Normalized source equality verified on 2026-08-14; line-ending differences
  account for the raw file hash difference.

## Cloud SQL Auth Proxy

- Source: `gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.25.4`
- Linux x86-64 manifest:
  `sha256:b0183dada4394925de5ca2ca833ef04706cb0a15a725be18c4c62e83eeae69ac`
- Source project license: Apache-2.0
- Docker Scout comparison: 13 Critical and 30 High findings in 2.14.1;
  zero Critical and zero High findings in 2.25.4.
- Artifact Analysis completed successfully for the staged 2.25.4 image and
  returned no package-vulnerability occurrences.
- Any Standard Kubernetes release that uses this image must mirror and scan it,
  apply the new product's service-name annotation, and use the release track
  and exact version selected for that product.

## PostgreSQL migration client

- Build definition: `marketplace/postgres-client.Dockerfile`
- Base: Alpine 3.24 Linux x86-64 manifest
  `sha256:79ff19e9084a00eece421b2523fb93e22d730e2c0e525905de047e848e56d95f`
- Installed client package: `postgresql16-client` version `16.15-r0`.
- The image contains `psql` and `pg_isready` for the Auth schema migration;
  it does not contain the PostgreSQL server or `gosu`.
- Runtime user: non-root UID/GID 10001.
- Linux x86-64 manifest:
  `sha256:66714e1531e792ee06f22ed44362874c6d51a8d0bd373b4c9e952c1dc832324f`
- Docker Scout and Artifact Analysis returned no package vulnerabilities.
- Alpine, PostgreSQL, BusyBox, OpenSSL, and all transitive package licenses
  must be verified from the final SBOM during release review.
- Any Standard Kubernetes release that uses this image must mirror and scan it,
  apply the new product's service-name annotation, and use the release track
  and exact version selected for that product.

Do not replace these digest-pinned inputs with mutable source tags during a
release. Any source change requires a new inventory entry and another security
and legal review.
