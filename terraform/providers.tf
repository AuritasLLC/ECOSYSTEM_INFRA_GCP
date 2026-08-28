provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  default_labels = local.common_labels
}

data "google_client_config" "current" {}

data "google_project" "customer" {
  project_id = var.project_id
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.asm_plus.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.asm_plus.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.asm_plus.endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.asm_plus.master_auth[0].cluster_ca_certificate)
  }

  registries = [{
    url      = "oci://us-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.current.access_token
  }]
}
