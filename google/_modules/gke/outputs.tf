output "ingress_zone_name_servers" {
  value       = google_dns_managed_zone.current.name_servers
  description = "Nameservers of the cluster's managed zone."
}

output "pipeline_id_rsa.pub" {
  value       = tls_private_key.pipeline.public_key_openssh
  description = "Public key used for the pipeline in OpenSSH format."
}
