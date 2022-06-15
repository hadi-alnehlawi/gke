data "google_client_config" "current" {
}



module "gcp_network" {
    source  = "terraform-google-modules/network/google//modules/subnets"
    version = "> 2.0.0"

  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "21.1.0"
  # insert the 10 required variables here
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  initial_node_count         = var.num_node

  node_pools = [
    {
      name                      = "gke-node-pool1"
      min_count                 = 1
      max_count                 = 1
      preemptible               = var.preemptible
    },
  ]

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}


module "gke-workload-identity" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name         = "messenger"
  namespace    = "publisher"
  project_id   = var.project_id
  cluster_name = var.cluster_name
  roles        = ["roles/storage.admin", "roles/compute.admin", "roles/pubsub.admin"]
}


