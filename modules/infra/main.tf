# where in the cloud are we
provider "google" {
  project = var.project_id
  region  = var.region
}

# keep it fresh and random
resource "random_string" "role_suffix" {
  length  = 8
  special = false
}

# erect outer wall
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# add inner sanctum
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# spin up cluster inside
resource "google_container_cluster" "demo" {
  name     = "${var.project_id}-gke"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

#  add a fancy pools
resource "google_container_node_pool" "pools" {
  for_each = {
    blue    = ["us-east1-b"]
    green   = ["us-east1-c"]
  }
  name       = "${google_container_cluster.demo.name}-node-pool-${each.key}"
  location   = var.region
  node_locations = each.value
  cluster    = google_container_cluster.demo.name
  node_count = var.gke_num_nodes
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    labels = {
      env     = var.project_id,
      stack   = "${each.key}",
    }
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke", "${each.key}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_service_account" "accounts" {
  for_each      = toset( ["reader", "admin"] )
  account_id    = "gke-${each.key}-rbac"
  display_name  = "GKE ${each.key} RBAC"
}

# create a new custom k8s API reader role
resource "google_project_iam_custom_role" "kube-api-reader" {
  role_id = "kube_api_reader_${random_string.role_suffix.result}"
  title = "API Reader Role"
  permissions = [
    "container.apiServices.get",
    "container.apiServices.list",
    "container.clusters.get",
    "container.clusters.getCredentials",
  ]
}

# bind Admin w/ default container Admin role
resource "google_project_iam_member" "kube-api-admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.accounts["admin"].email}"
}

# bind reader w/ custom reader role
resource "google_project_iam_binding" "kube-api-reader" {
  role = "projects/${var.project_id}/roles/${google_project_iam_custom_role.kube-api-reader.role_id}"

  members = [
    "serviceAccount:${google_service_account.accounts["reader"].email}",
  ]
}

# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only.
# # It references the variables and resources provisioned in this file.
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.demo.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.demo.master_auth.0.client_certificate
#   client_key             = google_container_cluster.demo.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.demo.master_auth.0.cluster_ca_certificate
# }
