locals {
  foundation_services = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  required_services = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ])

  common_labels = merge(
    {
      application = "asm-plus"
      managed-by  = "terraform"
      deployment  = "cloud-marketplace"
    },
    var.marketplace_consumption_label == "" ? {} : {
      goog-partner-solution = var.marketplace_consumption_label
    }
  )

  gcs_bucket_name = var.gcs_bucket_name == "" ? "${var.project_id}-asmplus-data" : var.gcs_bucket_name

  cloudsql_ksa_name           = "asmplus-cloudsql-client"
  cloudsql_migration_ksa_name = "asmplus-cloudsql-migrations"
  asm_ksa_name                = "asm-api"
  runtime_secret_name         = "asmplus-runtime-secrets"

  base_hostnames = {
    auth         = "auth.${var.domain_suffix}"
    api_auth     = "api-auth.${var.domain_suffix}"
    app          = "app.${var.domain_suffix}"
    api_asm_plus = "api-asm-plus.${var.domain_suffix}"
    viewer       = "viewer.${var.domain_suffix}"
  }

  optional_hostnames = merge(
    var.enable_sap_business_api ? {
      api_sap = "api-sap.${var.domain_suffix}"
    } : {},
    var.enable_successfactors_api ? {
      api_sf = "api-sf.${var.domain_suffix}"
    } : {}
  )

  hostnames = merge(local.base_hostnames, local.optional_hostnames)

  image_repositories = {
    api-asm        = var.api_asm_image_repo
    api-auth       = var.api_auth_image_repo
    api-asm-plus   = var.api_asm_plus_image_repo
    front-auth     = var.front_auth_image_repo
    front-asm-plus = var.front_asm_plus_image_repo
    front-viewer   = var.front_viewer_image_repo
    api-sap        = var.api_sap_image_repo
    api-sf         = var.api_sf_image_repo
  }

  image_tags = {
    api-asm        = var.api_asm_image_tag
    api-auth       = var.api_auth_image_tag
    api-asm-plus   = var.api_asm_plus_image_tag
    front-auth     = var.front_auth_image_tag
    front-asm-plus = var.front_asm_plus_image_tag
    front-viewer   = var.front_viewer_image_tag
    api-sap        = var.api_sap_image_tag
    api-sf         = var.api_sf_image_tag
  }

  effective_secrets = {
    ASM_API_KEY                = random_password.asm_api_key.result
    JWT_SECRET                 = random_password.auth_jwt_secret.result
    AUTH_SUPER_ADMIN_PASSWORD  = random_password.auth_superadmin_password.result
    PGPASSWORD                 = random_password.postgres_password.result
    AUTH_CLIENT_KEY            = random_password.auth_client_key.result
    AUTH_CLIENT_KEY_FRONT_AUTH = ""
    SAP_BASIC_AUTH_USERS_JSON  = var.sap_basic_auth_users_json
    SF_MANAGED_USERS_JSON      = var.sf_managed_users_json
    VECTOR_API_KEY             = ""
  }

  secret_manager_payloads = {
    asm-api-key                    = local.effective_secrets.ASM_API_KEY
    auth-client-key-front-asm-plus = local.effective_secrets.AUTH_CLIENT_KEY
    auth-jwt-secret                = local.effective_secrets.JWT_SECRET
    auth-superadmin-password       = local.effective_secrets.AUTH_SUPER_ADMIN_PASSWORD
    postgres-password              = local.effective_secrets.PGPASSWORD
    sap-basic-auth-users-json      = local.effective_secrets.SAP_BASIC_AUTH_USERS_JSON
    sf-managed-users-json          = local.effective_secrets.SF_MANAGED_USERS_JSON
  }

  # Keep for_each keys non-sensitive. Terraform propagates sensitivity from
  # random passwords to the payload map, which cannot be used as for_each.
  secret_ids = toset([
    "asm-api-key",
    "auth-client-key-front-asm-plus",
    "auth-jwt-secret",
    "auth-superadmin-password",
    "postgres-password",
    "sap-basic-auth-users-json",
    "sf-managed-users-json",
  ])

  rendered_migration_values = templatefile("${path.module}/templates/values-gcp.yaml.tftpl", {
    project_id                    = var.project_id
    region                        = var.region
    namespace                     = var.namespace
    gcs_bucket_name               = local.gcs_bucket_name
    runtime_secret_name           = local.runtime_secret_name
    static_ip_name                = google_compute_global_address.ingress.name
    domain_suffix                 = var.domain_suffix
    managed_certificate_name      = "asmplus-certificate"
    frontend_config_name          = "asmplus-frontend-config"
    allow_http                    = true
    cloudsql_instance_name        = google_sql_database_instance.asm_plus.name
    cloudsql_database             = var.cloudsql_database
    cloudsql_user                 = var.cloudsql_user
    cloudsql_gsa_name             = google_service_account.cloudsql.account_id
    cloudsql_ksa_name             = local.cloudsql_migration_ksa_name
    asm_gsa_name                  = google_service_account.asm_api.account_id
    asm_ksa_name                  = local.asm_ksa_name
    admin_email                   = var.admin_email
    viewer_auth_app_id            = "2"
    image_repositories            = local.image_repositories
    image_tags                    = local.image_tags
    cloud_sql_proxy_image_repo    = var.cloud_sql_proxy_image_repo
    cloud_sql_proxy_image_tag     = var.cloud_sql_proxy_image_tag
    postgres_image_repo           = var.postgres_image_repo
    postgres_image_tag            = var.postgres_image_tag
    marketplace_consumption_label = var.marketplace_consumption_label
    marketplace_service_name      = var.marketplace_service_name
    marketplace_service_level     = var.marketplace_service_level
  })

  rendered_application_values = templatefile("${path.module}/templates/values-gcp.yaml.tftpl", {
    project_id                    = var.project_id
    region                        = var.region
    namespace                     = var.namespace
    gcs_bucket_name               = local.gcs_bucket_name
    runtime_secret_name           = local.runtime_secret_name
    static_ip_name                = google_compute_global_address.ingress.name
    domain_suffix                 = var.domain_suffix
    managed_certificate_name      = "asmplus-certificate"
    frontend_config_name          = "asmplus-frontend-config"
    allow_http                    = true
    cloudsql_instance_name        = google_sql_database_instance.asm_plus.name
    cloudsql_database             = var.cloudsql_database
    cloudsql_user                 = var.cloudsql_user
    cloudsql_gsa_name             = google_service_account.cloudsql.account_id
    cloudsql_ksa_name             = local.cloudsql_ksa_name
    asm_gsa_name                  = google_service_account.asm_api.account_id
    asm_ksa_name                  = local.asm_ksa_name
    admin_email                   = var.admin_email
    viewer_auth_app_id            = "2"
    image_repositories            = local.image_repositories
    image_tags                    = local.image_tags
    cloud_sql_proxy_image_repo    = var.cloud_sql_proxy_image_repo
    cloud_sql_proxy_image_tag     = var.cloud_sql_proxy_image_tag
    postgres_image_repo           = var.postgres_image_repo
    postgres_image_tag            = var.postgres_image_tag
    marketplace_consumption_label = var.marketplace_consumption_label
    marketplace_service_name      = var.marketplace_service_name
    marketplace_service_level     = var.marketplace_service_level
  })

  rendered_app_phase_values = templatefile("${path.module}/templates/values-applications.yaml.tftpl", {
    enable_sap_business_api   = var.enable_sap_business_api
    enable_successfactors_api = var.enable_successfactors_api
  })
}
