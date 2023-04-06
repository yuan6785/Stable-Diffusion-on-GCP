data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "terraform.tfstate"
  }
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.gke.outputs.region
}

provider "kubernetes" {
  host = "https://${data.terraform_remote_state.gke.outputs.kubernetes_cluster_host}"
  #  data.terraform_remote_state.gke.outputs.kubernetes_cluster_host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_storage_class" "nfs" {
  metadata {
    name = "filestore"
  }
  reclaim_policy      = "Retain"
  storage_provisioner = "nfs"
}

resource "kubernetes_persistent_volume_v1" "nfs_pv" {
  metadata {
    name = "filestore-nfs-pv"
  }
  spec {
    capacity = {
      storage = "1Ti"
    }
    storage_class_name = kubernetes_storage_class.nfs.metadata[0].name
    access_modes       = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path   = "/vol1"
        server = data.terraform_remote_state.gke.outputs.google_filestore_reserved_ip_range
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "nfs_pvc" {
  metadata {
    name = "vol1"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.nfs.metadata[0].name
    volume_name        = kubernetes_persistent_volume_v1.nfs_pv.metadata.0.name
    resources {
      requests = {
        storage = "1Ti"
      }
    }
  }
}

