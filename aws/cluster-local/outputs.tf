output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}

output "current_metadata" {
  value = module.cluster_metadata
}

output "kubeconfig" {
  value = module.cluster.kubeconfig
}
