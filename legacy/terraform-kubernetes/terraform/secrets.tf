resource "random_password" "asm_api_key" {
  length  = 64
  special = false
}

resource "random_password" "auth_jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "auth_superadmin_password" {
  length           = 32
  special          = true
  override_special = "_%@-"
}

resource "random_password" "postgres_password" {
  length           = 32
  special          = true
  override_special = "_%@-"
}

resource "random_password" "auth_client_key" {
  length  = 64
  special = false
}

resource "google_secret_manager_secret" "runtime" {
  for_each = local.secret_ids

  project             = var.project_id
  secret_id           = each.key
  labels              = local.common_labels
  deletion_protection = false

  replication {
    auto {}
  }

  depends_on = [google_project_service.required["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "runtime" {
  for_each = local.secret_ids

  secret      = google_secret_manager_secret.runtime[each.key].id
  secret_data = local.secret_manager_payloads[each.key]
}
