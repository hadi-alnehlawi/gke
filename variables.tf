variable "project_id" {}
variable "network" {}
variable subnetwork {}
variable "cluster_name" {}
variable "region"{}
variable "zones" {
    type=list
}
variable preemptible {}
variable num_node {}
variable ip_range_pods_name{}
variable ip_range_services_name{}



