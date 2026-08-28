# ASM+ Marketplace Terraform module

This is the root Terraform module packaged for Google Cloud Marketplace and
executed by Infrastructure Manager in a customer's project.

The module intentionally has no backend block. It creates a dedicated VPC,
zonal x86 GKE cluster, private Cloud SQL instance, protected data bucket,
Secret Manager secrets, Workload Identity bindings, DNS records when selected,
and two ordered Helm releases. The first Helm release runs the database jobs;
the second installs ASM+ after those jobs succeed.

The optional SAP Business and SAP SuccessFactors connectors are controlled by
independent inputs. Disabled connectors do not create workloads, ingress
routes, managed-certificate domains, DNS records, or application URL outputs.

`schema.yaml` identifies the image variables that Marketplace replaces during
release validation and publication. Do not put `project_id`, chart variables,
or any schema image variable in `marketplace_test.tfvars`.

Local checks do not create cloud resources:

```powershell
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
```

An actual plan requires a billing-enabled test project, approved deployment
credentials, the published OCI chart and images, and the Portal-assigned
Marketplace values.

Use the [Deployment and User Guide](../docs/USER_GUIDE.md) for Marketplace
installation, verification, backup, update, scaling, and deletion procedures.
Do not deploy this source directly with development images or mutable tags.
