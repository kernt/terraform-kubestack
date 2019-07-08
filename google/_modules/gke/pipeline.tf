resource "google_service_account" "pipeline" {
  account_id = "${var.metadata_name}-pipeline"
  project    = var.project
}

resource "google_project_iam_member" "container_admin" {
  project = var.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "editor" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "tls_private_key" "pipeline" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "kubernetes_namespace" "pipeline" {
  provider = kubernetes.gke

  metadata {
    name = "kbst-pipeline"
  }

  # namespace metadata may change through the manifests
  # hence ignoring this for the terraform lifecycle
  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [module.node_pool]
}

resource "kubernetes_secret" "pipeline" {
  metadata {
    name      = "${var.metadata_name}-pipeline-sshkey"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
    annotations = {
      "tekton.dev/git-0" : "github.com"
    }
  }

  data = {
    "ssh-privatekey" = tls_private_key.pipeline.private_key_pem
    "known_hosts"    = "Z2l0aHViLmNvbSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFCSXdBQUFRRUFxMkE3aFJHbWRubTl0VURiTzlJRFN3Qks2VGJRYStQWFlQQ1B5NnJiVHJUdHc3UEhrY2NLcnBwMHlWaHA1SGRFSWNLcjZwTGxWREJmT0xYOVFVc3lDT1Ywd3pmaklKTmxHRVlzZGxMSml6SGhibjJtVWp2U0FIUXFaRVRZUDgxZUZ6TFFOblBIdDRFVlZVaDdWZkRFU1U4NEtlem1ENVFsV3BYTG12VTMxL3lNZitTZTh4aEhUdktTQ1pJRkltV3dvRzZtYlVvV2Y5bnpwSW9hU2pCK3dlcXFVVW1wYWFhc1hWYWw3MkorVVgyQisyUlBXM1JjVDBlT3pRZ3FsSkwzUktyVEp2ZHNqRTNKRUF2R3EzbEdIU1pYeTI4RzNza3VhMlNtVmkvdzR5Q0U2Z2JPRHFuVFdsZzcrd0M2MDR5ZEdYQThWSmlTNWFwNDNKWGlVRkZBYVE9PQo="
  }

  type = "kubernetes.io/ssh-auth"
}

resource "kubernetes_service_account" "pipeline" {
  metadata {
    name      = "kbst-pipeline"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.pipeline.email
    }
  }

  secret {
    #name = kubernetes_secret.pipeline.metadata.0.name
    name = "ssh-auth"
  }
}
