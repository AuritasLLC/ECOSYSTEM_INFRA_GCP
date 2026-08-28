resource "google_service_account" "asm_api" {
  account_id   = "asm-api"
  display_name = "ASM API Workload Identity"
  project      = var.project_id

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_service_account" "cloudsql" {
  account_id   = "asmplus-cloudsql-client"
  display_name = "ASM+ Cloud SQL client Workload Identity"
  project      = var.project_id

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql.email}"
}

resource "google_service_account_iam_member" "asm_api_workload_identity" {
  service_account_id = google_service_account.asm_api.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${local.asm_ksa_name}]"

  depends_on = [google_container_cluster.asm_plus]
}

resource "google_service_account_iam_member" "cloudsql_workload_identity" {
  for_each = toset([
    local.cloudsql_ksa_name,
    local.cloudsql_migration_ksa_name,
  ])

  service_account_id = google_service_account.cloudsql.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${each.value}]"

  depends_on = [google_container_cluster.asm_plus]
}
