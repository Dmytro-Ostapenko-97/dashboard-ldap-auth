# Kubernetes Dashboard
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    annotations = {
      name      = var.namespace
    }
    name        = var.namespace
  }
}

#Dashboard
resource "helm_release" "dashboard" {
  name            = local.dashboard_chart
  repository      = local.dashboard_repository
  chart           = local.dashboard_chart
  namespace       = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  cleanup_on_fail = true
  version         = var.chart_version

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.hosts[0]"
    value = "${var.dashboard_subdomain}${var.domain}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "${var.dashboard_subdomain}${var.domain}"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = var.tls
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/whitelist-source-range"
    value = replace(var.cidr_whitelist, ",", "\\,")
    type  = "string"
  }
  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }
  set {
    name  = "rbac.clusterReadOnlyRole"
    value = var.readonly_user
  }

  dynamic "set" {
    for_each  = var.enable_skip_button ? [{}] : []
    content {
        name  = "extraArgs[0]"
        value = "--enable-skip-login"
    }
  }

  dynamic "set" {
    for_each = var.additional_set
    content {
      name   = set.value.name
      value  = set.value.value
      type   = lookup(set.value, "type", null )
    }
  }
}

# Admin Token
resource "kubernetes_service_account" "admin_service_account" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name      = local.dashboard_admin_service_account
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  automount_service_account_token = true
}
resource "kubernetes_cluster_role_binding" "admin_role_binding" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name = local.dashboard_admin_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin_service_account[0].metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}
data "kubernetes_secret" "admin_token" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name      = kubernetes_service_account.admin_service_account[0].default_secret_name
    namespace = kubernetes_namespace.namespace[0].id
  }
}

module "ldap_auth" {
  source = "./ldap"

  count = var.create_ldap_auth ? 1 : 0

  namespace = kubernetes_namespace.namespace[0].metadata[0].name
  auth_service_name = "ldap-auth-service"
  admin_service_account = kubernetes_service_account.admin_service_account[0].metadata[0].name
  user_service_account = "kubernetes-dashboard-user"
  read_only_account = "kubernetes-dashboard-read-only"

  #LDAP parameters
  ldap_password = var.ldap_reader_password
  ldap_domain_name = "local.dermpro.com"
  ldap_dn_search = "ou=dermpro,dc=local,dc=dermpro,dc=com"
  ldap_attributes = "sAMAccountName,memberOf"
  ldap_scope = "sub"
  ldap_filter = "(objectClass=*)"

  eks_cluster_name = "dermpro-eks-dev"

}