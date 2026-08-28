mock_provider "google" {
  mock_data "google_client_config" {
    defaults = {
      access_token = "mock-access-token"
    }
  }

  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  mock_resource "google_container_cluster" {
    defaults = {
      endpoint = "127.0.0.1"
      master_auth = [{
        cluster_ca_certificate = "ZmFrZS1jYQ=="
      }]
    }
  }

  mock_resource "google_compute_global_address" {
    defaults = {
      address = "203.0.113.10"
    }
  }

  mock_resource "google_sql_database_instance" {
    defaults = {
      connection_name = "asmplus-marketplace-test:us-east1:asmplus-postgres"
    }
  }
}

mock_provider "helm" {}
mock_provider "kubernetes" {}
mock_provider "random" {}

variables {
  project_id      = "asmplus-marketplace-test"
  region          = "us-east1"
  zone            = "us-east1-b"
  domain_suffix   = "asmplus.example.com"
  admin_email     = "admin@example.com"
  helm_chart_repo = "oci://us-docker.pkg.dev/example-public/example/asmplus"
}

run "marketplace_single_apply_plan" {
  command = plan

  assert {
    condition     = helm_release.migrations.wait_for_jobs == true
    error_message = "The migration release must wait for database Jobs."
  }

  assert {
    condition     = helm_release.asm_plus.wait_for_jobs == false
    error_message = "The application release must not wait for disabled migration Jobs."
  }

  assert {
    condition     = helm_release.asm_plus.name == "asm-plus"
    error_message = "The application release name must remain stable."
  }

  assert {
    condition     = google_storage_bucket.asm_binaries.public_access_prevention == "enforced"
    error_message = "The ASM+ data bucket must prevent public access."
  }

  assert {
    condition     = google_sql_database_instance.asm_plus.settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "Cloud SQL must not receive a public IPv4 address."
  }

  assert {
    condition     = google_container_cluster.asm_plus.deletion_protection == false
    error_message = "Marketplace-managed deployments must remain removable by Infrastructure Manager."
  }

  assert {
    condition     = length(local.hostnames) == 5 && !contains(keys(local.hostnames), "api_sap") && !contains(keys(local.hostnames), "api_sf")
    error_message = "Disabled optional connectors must not publish DNS records or application URLs."
  }
}

run "successfactors_connector_only_plan" {
  command = plan

  variables {
    enable_successfactors_api = true
  }

  assert {
    condition     = length(local.hostnames) == 6 && contains(keys(local.hostnames), "api_sf") && !contains(keys(local.hostnames), "api_sap")
    error_message = "The SAP SuccessFactors connector must be independently deployable."
  }

  assert {
    condition     = strcontains(local.rendered_app_phase_values, "api-sf:\n  enabled: true") && strcontains(local.rendered_app_phase_values, "api-sap:\n  enabled: false")
    error_message = "Helm application values must independently enable only SAP SuccessFactors."
  }
}
