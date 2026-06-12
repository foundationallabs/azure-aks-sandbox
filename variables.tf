variable "nuon_id" {
  type        = string
  description = "The nuon id for this install. Used for naming purposes."
}

variable "location" {
  type        = string
  description = "The location to launch the cluster in"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version to use for the AKS cluster."
  default     = "1.33"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The image size."
}

variable "node_count" {
  type        = number
  default     = 2
  description = "The minimum number of nodes in the managed node pool."
}

variable "node_max_pods" {
  type        = number
  default     = 15
  description = "Maximum pods per node in the managed (default) node pool. Lower this to reduce per-node Azure CNI IP pre-allocation (each node reserves max_pods + 1 IPs from the subnet). Constrained by the subnet size, especially during node pool rotations (vm_size changes) when temp pools double IP demand. Default 15 fits a /24 subnet through a 5-node rotation with headroom."
}

variable "vnet_name" {
  type        = string
  description = "The name of the existing Virtual Network created by Bicep."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group name where the existing Virtual Network is located."
}

variable "private_subnet_names" {
  type        = string
  description = "The subnets to deploy private resources into."
}

