variable "project_id" {
  description = "Customer GCP project where ASM+ is deployed. Marketplace supplies this value."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID."
  }
}

variable "region" {
  description = "Region for regional ASM+ resources."
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "Zone for the dedicated GKE cluster."
  type        = string
  default     = "us-east1-b"
}

variable "domain_suffix" {
  description = "Delegated DNS suffix for the required and enabled ASM+ endpoints, for example asmplus.example.com."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$", var.domain_suffix))
    error_message = "domain_suffix must be a fully qualified DNS suffix without a trailing dot."
  }
}

variable "admin_email" {
  description = "Initial ASM+ superadministrator email."
  type        = string

  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.admin_email))
    error_message = "admin_email must be a valid email address."
  }
}

variable "network_name" {
  description = "Dedicated VPC name."
  type        = string
  default     = "asmplus-vpc"
}

variable "subnetwork_name" {
  description = "Dedicated GKE subnet name."
  type        = string
  default     = "asmplus-gke-subnet"
}

variable "subnetwork_cidr" {
  description = "Primary GKE node CIDR."
  type        = string
  default     = "10.20.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary GKE Pod CIDR."
  type        = string
  default     = "10.24.0.0/14"
}

variable "services_cidr" {
  description = "Secondary GKE Service CIDR."
  type        = string
  default     = "10.28.0.0/20"
}

variable "private_services_prefix_length" {
  description = "Prefix length reserved for private service access."
  type        = number
  default     = 16

  validation {
    condition     = var.private_services_prefix_length >= 16 && var.private_services_prefix_length <= 24
    error_message = "private_services_prefix_length must be between 16 and 24."
  }
}

variable "cluster_name" {
  description = "Dedicated GKE cluster name."
  type        = string
  default     = "asmplus-gke"
}

variable "node_pool_name" {
  description = "GKE node pool name."
  type        = string
  default     = "asmplus-pool"
}

variable "node_machine_type" {
  description = "x86 GKE node machine type."
  type        = string
  default     = "e2-standard-4"
}

variable "node_disk_size_gb" {
  description = "Boot disk size for each GKE node."
  type        = number
  default     = 100
}

variable "min_nodes" {
  description = "Minimum GKE nodes."
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum GKE nodes."
  type        = number
  default     = 4
}

variable "namespace" {
  description = "Kubernetes namespace for ASM+."
  type        = string
  default     = "asm-plus"
}

variable "helm_release_name" {
  description = "Helm release name for the application workloads."
  type        = string
  default     = "asm-plus"
}

variable "helm_chart_repo" {
  description = "OCI Helm repository supplied by Cloud Marketplace."
  type        = string
  default     = "oci://us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus"
}

variable "helm_chart_name" {
  description = "Helm chart name supplied by Cloud Marketplace."
  type        = string
  default     = "ecosystem"
}

variable "helm_chart_version" {
  description = "Helm chart version supplied by Cloud Marketplace."
  type        = string
  default     = "1.0.0"
}

variable "helm_timeout_seconds" {
  description = "Maximum time for Helm migrations and application installation."
  type        = number
  default     = 1800
}

variable "gcs_bucket_name" {
  description = "Globally unique bucket for ASM+ binary objects. Empty derives a stable name from project_id."
  type        = string
  default     = ""

  validation {
    condition     = var.gcs_bucket_name == "" || can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.gcs_bucket_name))
    error_message = "gcs_bucket_name must be empty or a valid GCS bucket name."
  }
}

variable "gcs_force_destroy" {
  description = "Allow deletion of a non-empty ASM+ data bucket. Keep false to protect customer data."
  type        = bool
  default     = false
}

variable "cloudsql_instance_name" {
  description = "Cloud SQL PostgreSQL instance name."
  type        = string
  default     = "asmplus-postgres"
}

variable "cloudsql_database" {
  description = "ASM+ database name."
  type        = string
  default     = "auritasdemo"
}

variable "cloudsql_user" {
  description = "ASM+ database user."
  type        = string
  default     = "auritas"
}

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-2-7680"
}

variable "cloudsql_availability_type" {
  description = "Cloud SQL availability type."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.cloudsql_availability_type)
    error_message = "cloudsql_availability_type must be ZONAL or REGIONAL."
  }
}

variable "cloudsql_disk_size_gb" {
  description = "Initial Cloud SQL SSD disk size."
  type        = number
  default     = 20
}

variable "manage_dns_records" {
  description = "Create DNS records in an existing Cloud DNS managed zone."
  type        = bool
  default     = false
}

variable "dns_managed_zone_name" {
  description = "Cloud DNS managed zone name when manage_dns_records is true."
  type        = string
  default     = null
  nullable    = true
}

variable "enable_sap_business_api" {
  description = "Deploy the optional SAP Business API workload."
  type        = bool
  default     = false
}

variable "enable_successfactors_api" {
  description = "Deploy the optional SAP SuccessFactors API workload."
  type        = bool
  default     = false
}

variable "sap_basic_auth_users_json" {
  description = "Sensitive JSON consumed by the optional SAP Business API. Prefer post-deployment Secret Manager configuration because a supplied value is retained in Terraform state."
  type        = string
  default     = "{}"
  sensitive   = true

  validation {
    condition     = can(jsondecode(var.sap_basic_auth_users_json))
    error_message = "sap_basic_auth_users_json must be valid JSON."
  }
}

variable "sf_managed_users_json" {
  description = "Sensitive JSON consumed by the optional SAP SuccessFactors API. Prefer post-deployment Secret Manager configuration because a supplied value is retained in Terraform state."
  type        = string
  default     = "{}"
  sensitive   = true

  validation {
    condition     = can(jsondecode(var.sf_managed_users_json))
    error_message = "sf_managed_users_json must be valid JSON."
  }
}

variable "marketplace_consumption_label" {
  description = "goog-partner-solution value assigned to ASM+ in Producer Portal."
  type        = string
  default     = "isol_plb32_0014m00001irgbqqaq_g4sz646dffwwygzqyiappxoc7q5x4tjk"
}

variable "marketplace_service_name" {
  description = "Marketplace service name assigned to ASM+ in Producer Portal."
  type        = string
  default     = "asm-plus.endpoints.auritas-asmplus-public.cloud.goog"
}

variable "marketplace_service_level" {
  description = "Marketplace service level for usage-based pricing."
  type        = string
  default     = "default"
}

variable "api_asm_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/api-asm"
}
variable "api_asm_image_tag" {
  type    = string
  default = "1.0"
}
variable "api_auth_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/api-auth"
}
variable "api_auth_image_tag" {
  type    = string
  default = "1.0"
}
variable "api_asm_plus_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/api-asm-plus"
}
variable "api_asm_plus_image_tag" {
  type    = string
  default = "1.0"
}
variable "front_auth_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/front-auth"
}
variable "front_auth_image_tag" {
  type    = string
  default = "1.0"
}
variable "front_asm_plus_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/front-asm-plus"
}
variable "front_asm_plus_image_tag" {
  type    = string
  default = "1.0"
}
variable "front_viewer_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/front-viewer"
}
variable "front_viewer_image_tag" {
  type    = string
  default = "1.0"
}
variable "api_sap_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/api-sap"
}
variable "api_sap_image_tag" {
  type    = string
  default = "1.0"
}
variable "api_sf_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/api-sf"
}
variable "api_sf_image_tag" {
  type    = string
  default = "1.0"
}
variable "cloud_sql_proxy_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/cloud-sql-proxy"
}
variable "cloud_sql_proxy_image_tag" {
  type    = string
  default = "1.0"
}
variable "postgres_image_repo" {
  type    = string
  default = "us-docker.pkg.dev/auritas-asmplus-public/asmplus-marketplace/asmplus/postgres"
}
variable "postgres_image_tag" {
  type    = string
  default = "1.0"
}
