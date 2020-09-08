variable "create_admin_token" {
  description = "Create admin token for auth"
  default     = true
}
variable "create_user_token" {
  description = "Create user token for auth"
  default     = true
}
variable "create_read_only_token" {
  description = "Create read only token for auth"
  default     = false
}

variable "auth_service_name" {
  description = "Name of LDAP auth service for dashboard in k8s cluster"
  type = string
  default = "LDAP-auth"
}
variable "namespace" {
  description = "Namespace where dashboard deployed"
  type = string
}
variable "admin_service_account" {
  description = "Admin Service Account (full access)"
}
variable "user_service_account" {
  description = "User Service Account (access to special resources)"
}
variable "read_only_account" {
  description = "Read Only Service Account (low level access only for read)"
}
variable "service_ports" {
  description = "Ports for auth request from ingress to service"
  default = [
    {
      name = "auth"
      internal_port = "80"
      external_port = "80"
    }
  ]
}

# LDAP URL config
variable "ldap_domain_name" {
  description = "Host domain name where ldap deployed"
}
variable "ldap_port" {
  description = "Port number of the LDAP server"
  default = "389"
}
variable "ldap_dn_search" {
  description = "Distinguished name (DN) of an entry in the directory. This DN identifies the entry that is starting point of the search. If this component is empty, the search starts at the root DN."
}
variable "ldap_attributes" {
  description = "The attributes to be returned. To specify more than one attribute, use commas to delimit the attributes (for example, 'cn,mail,telephoneNumber'). If no attributes are specified in the URL, all attributes are returned."
  type = string
  default = "sAMAccountName,memberOf"
}
variable "ldap_scope" {
  description = "The scope of the search, which can be one of these values: base, one or sub"
  type = string
  default = "sub"
}
variable "ldap_filter" {
  description = ""
  type = string
  default = "(objectClass=*)"
}
variable "eks_cluster_name" {
  description = "Name of EKS cluster"
}
variable "aws_region" {
  description = "Region where EKS deployed"
  default = "us-east-1"
}
variable "ldap_password" {}