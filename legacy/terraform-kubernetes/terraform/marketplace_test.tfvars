# Cloud Marketplace supplies project_id, Helm chart variables, and all image
# variables during verification. Do not add those variables to this file.

region        = "us-east1"
zone          = "us-east1-b"
domain_suffix = "asmplus.example.com"
admin_email   = "admin@example.com"

cluster_name              = "asmplus-marketplace-test"
min_nodes                 = 1
max_nodes                 = 2
manage_dns_records        = false
enable_sap_business_api   = false
enable_successfactors_api = false
