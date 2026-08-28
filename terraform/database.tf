resource "google_sql_database_instance" "asm_plus" {
  name             = var.cloudsql_instance_name
  project          = var.project_id
  region           = var.region
  database_version = "POSTGRES_16"

  deletion_protection = false

  settings {
    tier                        = var.cloudsql_tier
    edition                     = "ENTERPRISE"
    availability_type           = var.cloudsql_availability_type
    disk_type                   = "PD_SSD"
    disk_size                   = var.cloudsql_disk_size_gb
    disk_autoresize             = true
    deletion_protection_enabled = false
    retain_backups_on_delete    = true

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.asm_plus.id
      allocated_ip_range                            = google_compute_global_address.private_services.name
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }

    user_labels = local.common_labels
  }

  depends_on = [
    google_project_service.required["sqladmin.googleapis.com"],
    google_service_networking_connection.private_services,
  ]

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}

resource "google_sql_database" "asm_plus" {
  name     = var.cloudsql_database
  project  = var.project_id
  instance = google_sql_database_instance.asm_plus.name
}

resource "google_sql_user" "asm_plus" {
  name     = var.cloudsql_user
  project  = var.project_id
  instance = google_sql_database_instance.asm_plus.name
  password = local.effective_secrets.PGPASSWORD
}
