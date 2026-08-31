# ASM+ Helm deployer source

The `chart/ecosystem` directory is the candidate ASM+ Helm chart imported from
the validated Terraform Kubernetes deployment. It is a starting point, not yet
a valid Standard Kubernetes Marketplace deployer.

Do not build or publish a deployer image until the following values are known
and applied consistently:

- Producer Portal partner ID.
- New Standard Kubernetes product/solution ID.
- New product service name.
- Artifact Registry image root.
- Release track and exact release version.
- BYOL license acquisition and validation contract.
- Verification database, object storage, and Workload Identity inputs.

After those decisions, add the final `schema.yaml`, deployer `Dockerfile`, and
`data-test` overlay, then run local `mpdev verify` before submitting images in
Producer Portal.
