variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-east1"
}

variable "project_id" {
  description = "The Project ID within GCP"
  type        = string
  default     = "elite-vault-341617"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}
