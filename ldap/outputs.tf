output "user_token" {
  value = var.create_user_token ? lookup(data.kubernetes_secret.user_token[0].data, "token") : "Not enabled"
}
output "read_only_token" {
  value = var.create_read_only_token ? lookup(data.kubernetes_secret.user_token[0].data, "token") : "Not enabled"
}
