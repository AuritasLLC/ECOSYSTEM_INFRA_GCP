output "project_id" {
  description = "Customer GCP project containing ASM+."
  value       = var.project_id
}

output "gke_cluster_name" {
  description = "Dedicated ASM+ GKE cluster name."
  value       = google_container_cluster.asm_plus.name
}

output "gke_cluster_location" {
  description = "Dedicated ASM+ GKE cluster location."
  value       = var.zone
}

output "namespace" {
  description = "ASM+ Kubernetes namespace."
  value       = var.namespace
}

output "cloudsql_instance_name" {
  description = "ASM+ Cloud SQL instance name."
  value       = google_sql_database_instance.asm_plus.name
}

output "gcs_bucket_name" {
  description = "Private ASM+ binary bucket."
  value       = google_storage_bucket.asm_binaries.name
}

output "ingress_ip" {
  description = "Global IPv4 address for ASM+ endpoints."
  value       = google_compute_global_address.ingress.address
}

output "dns_records" {
  description = "DNS A records that must point to ingress_ip when manage_dns_records is false."
  value = {
    for key, hostname in local.hostnames : hostname => google_compute_global_address.ingress.address
  }
}

output "application_urls" {
  description = "ASM+ HTTPS endpoints."
  value = {
    for key, hostname in local.hostnames : key => "https://${hostname}"
  }
}

output "generated_credentials_notice" {
  description = "How to retrieve generated runtime credentials."
  value       = "Generated credentials are stored in Secret Manager and are never printed as Terraform outputs."
}
