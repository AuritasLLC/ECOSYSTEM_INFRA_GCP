resource "google_storage_bucket" "asm_binaries" {
  name                        = local.gcs_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.gcs_force_destroy
  labels                      = local.common_labels

  versioning {
    enabled = true
  }

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  depends_on = [google_project_service.required["storage.googleapis.com"]]
}

resource "google_storage_bucket_iam_member" "asm_api_objects" {
  bucket = google_storage_bucket.asm_binaries.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.asm_api.email}"
}
