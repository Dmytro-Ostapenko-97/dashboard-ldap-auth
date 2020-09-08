# Admin Token
data "kubernetes_service_account" "admin_service_account" {
  metadata {
    name      = var.admin_service_account
    namespace = var.namespace
  }
}

# User Token
resource "kubernetes_service_account" "user_service_account" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name      = var.user_service_account
    namespace = var.namespace
  }
  automount_service_account_token = true
}
resource "kubernetes_cluster_role" "user_cluster_role" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name = "${var.user_service_account}-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}
resource "kubernetes_cluster_role_binding" "user_role_binding" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name = var.user_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.user_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.user_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}
data "kubernetes_secret" "user_token" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name      = kubernetes_service_account.user_service_account[0].default_secret_name
    namespace = var.namespace
  }
}


# Read Only Token
resource "kubernetes_service_account" "read_only_service_account" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name      = var.read_only_account
    namespace = var.namespace
  }
  automount_service_account_token = true
}
resource "kubernetes_cluster_role" "read_only_cluster_role" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name = "${var.read_only_account}-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["watch"]
  }
}
resource "kubernetes_cluster_role_binding" "read_only_role_binding" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name = var.read_only_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_only_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.read_only_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}
data "kubernetes_secret" "read_only_token" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name      = kubernetes_service_account.read_only_service_account[0].default_secret_name
    namespace = var.namespace
  }
}

# Auth service deployment
module "auth_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.5"

  name = "dashboard-ldap-auth"
  namespace = var.namespace
  image = "admindod/k8s_ldap_auth:v1.0.9"
  internal_port = 80
  custom_labels = {
    app = "dashboard-ldap-auth"
  }
  env = local.auth_env
  env_secret = local.auth_env_secret
}
module "auth_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name = module.auth_deploy.name
  app_namespace = var.namespace
  port_mapping = var.service_ports
  type = "NodePort"
  custom_labels = {
    app = "${module.auth_deploy.name}"
    primary = "true"
  }
}

# Deployment of service for recreate new tokens for service account users
module "recreate_token_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.5"

  name = "tokens-for-dashboard"
  namespace = var.namespace
  image = "admindod/genarate-tokens:v1.0.8"
  tty = true
  custom_labels = {
    app = "tokens-for-dashboard"
  }
  env = local.tokens_env
}
module "recreate_token_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name = module.recreate_token_deploy.name
  app_namespace = var.namespace
  port_mapping = var.service_ports
  type = "NodePort"
  custom_labels = {
    app = "${module.recreate_token_deploy.name}"
    primary = "true"
  }
}

resource "kubernetes_secret" "pswd_secrets" {
  metadata {
    name = "password-secrets"
    namespace = var.namespace
  }

  data = {
    LDAP_BIND_PASSWORD = var.ldap_password
  }

  type = "Opaque"
}
