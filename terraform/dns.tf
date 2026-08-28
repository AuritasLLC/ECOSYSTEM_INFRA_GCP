resource "google_dns_record_set" "applications" {
  for_each = var.manage_dns_records ? local.hostnames : {}

  project      = var.project_id
  managed_zone = var.dns_managed_zone_name
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.ingress.address]

  depends_on = [google_project_service.required["dns.googleapis.com"]]
}
