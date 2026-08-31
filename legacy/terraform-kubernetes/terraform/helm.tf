resource "helm_release" "migrations" {
  name      = "${var.helm_release_name}-migrations"
  namespace = kubernetes_namespace_v1.asm_plus.metadata[0].name

  repository = var.helm_chart_repo
  chart      = var.helm_chart_name
  version    = var.helm_chart_version

  atomic           = true
  cleanup_on_fail  = true
  create_namespace = false
  timeout          = var.helm_timeout_seconds
  wait             = true
  wait_for_jobs    = true

  values = [
    local.rendered_migration_values,
    file("${path.module}/templates/values-migrations.yaml"),
  ]

  depends_on = [
    google_service_account_iam_member.cloudsql_workload_identity,
    google_sql_database.asm_plus,
    google_sql_user.asm_plus,
    kubernetes_secret_v1.runtime,
    terraform_data.configuration_checks,
  ]
}

resource "helm_release" "asm_plus" {
  name      = var.helm_release_name
  namespace = kubernetes_namespace_v1.asm_plus.metadata[0].name

  repository = var.helm_chart_repo
  chart      = var.helm_chart_name
  version    = var.helm_chart_version

  atomic           = true
  cleanup_on_fail  = true
  create_namespace = false
  timeout          = var.helm_timeout_seconds
  wait             = true
  wait_for_jobs    = false

  values = [
    local.rendered_application_values,
    local.rendered_app_phase_values,
  ]

  depends_on = [
    helm_release.migrations,
    google_service_account_iam_member.asm_api_workload_identity,
    google_storage_bucket_iam_member.asm_api_objects,
  ]
}
