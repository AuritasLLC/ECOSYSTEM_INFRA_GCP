resource "google_project_service" "foundation" {
  for_each = local.foundation_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false

  depends_on = [google_project_service.foundation]
}

resource "terraform_data" "configuration_checks" {
  input = {
    project_id         = var.project_id
    zone               = var.zone
    region             = var.region
    sap_business_api   = var.enable_sap_business_api
    successfactors_api = var.enable_successfactors_api
    manage_dns_records = var.manage_dns_records
  }

  lifecycle {
    precondition {
      condition     = startswith(var.zone, "${var.region}-")
      error_message = "zone must belong to region."
    }

    precondition {
      condition     = !var.manage_dns_records || var.dns_managed_zone_name != null
      error_message = "dns_managed_zone_name is required when manage_dns_records is true."
    }

    precondition {
      condition     = var.min_nodes >= 1 && var.max_nodes >= var.min_nodes
      error_message = "min_nodes must be at least 1 and max_nodes must be greater than or equal to min_nodes."
    }
  }
}
