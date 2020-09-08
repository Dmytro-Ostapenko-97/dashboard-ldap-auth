locals {
  tokens_env = [
    {
      name = ADMIN_TOKEN_NAME
      value = "kubernetes-dashboard-admin-token-test"
    },
    {
      name = USER_TOKEN_NAME
      value = "kubernetes-dashboard-user-token-test"
    },
    {
      name = READ_ONLY_TOKEN_NAME
      value = "kubernetes-dashboard-readonly-token-test"
    },
    {
      name = ADMIN_SERVICE_ACCOUNT_NAME
      value = data.kubernetes_service_account.admin_service_account[0].metadata[0].name
    },
    {
      name = USER_SERVICE_ACCOUNT_NAME
      value = kubernetes_service_account.user_service_account[0].metadata[0].name
    },
    {
      name = READ_ONLY_SERVICE_ACCOUNT_NAME
      value = kubernetes_service_account.read_only_service_account[0].metadata[0].name
    },
    {
      name = NAMESPACE
      value = var.namespace
    },
    {
      name = EKS_CLUSTER_NAME
      value = var.eks_cluster_name
    }
  ]
  auth_env = [
    {
      name = ADMIN_GROUP
      value = "dashboard-admin"
    },
    {
      name = USER_GROUP
      value = "dashboard-user"
    },
    {
      name = READ_ONLY_GROUP
      value = "dashboard-read-only"
    },
    {
      name = AUTH_NAME
      value = "Authenticate for access to K8s dashboard"
    },
    {
      name = LDAP_BIND_DN
      value = "cn=reader,ou=users,${var.ldap_dn_search}"
    },
    {
      name = LDAP_REQUIRED_GROUP
      value = "cn=dashboard-login,ou=groups,${var.ldap_dn_search}"
    },
    {
      name = LDAP_URL
      value = "ldap://${var.ldap_domain_name}:${var.ldap_port}/${var.ldap_dn_search}?${var.ldap_attributes}?${var.ldap_scope}?${var.ldap_filter}"
    }
  ]
  auth_env_secret = [
    {
      name = DASHBOARD_ADMIN_TOKEN
      secret_name = data.kubernetes_service_account.admin_service_account[0].default_secret_name
      secret_key = "token"
    },
    {
      name = DASHBOARD_USER_TOKEN
      secret_name = data.kubernetes_secret.user_token[0].metadata[0].name
      secret_key = "token"
    },
    {
      name = DASHBOARD_READ_ONLY_TOKEN
      secret_name = data.kubernetes_secret.read_only_token[0].metadata[0].name
      secret_key = "token"
    },
    {
      name = LDAP_BIND_PASSWORD
      secret_name = kubernetes_secret.pswd_secrets.data[0].LDAP_BIND_PASSWORD
      secret_key = "LDAP_BIND_PASSWORD"
    },
  ]
}