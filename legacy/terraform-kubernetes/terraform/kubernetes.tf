resource "kubernetes_namespace_v1" "asm_plus" {
  metadata {
    name = var.namespace

    labels = merge(
      {
        "app.kubernetes.io/part-of"    = "asm-plus"
        "app.kubernetes.io/managed-by" = "terraform"
      },
      var.marketplace_consumption_label == "" ? {} : {
        "goog-partner-solution" = var.marketplace_consumption_label
      }
    )
  }

  depends_on = [google_container_node_pool.asm_plus]
}

resource "kubernetes_secret_v1" "runtime" {
  metadata {
    name      = local.runtime_secret_name
    namespace = kubernetes_namespace_v1.asm_plus.metadata[0].name
  }

  data = local.effective_secrets
  type = "Opaque"

  depends_on = [google_secret_manager_secret_version.runtime]
}
