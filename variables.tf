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
  description = "Initial (desired) number of nodes in the managed node pool. Must be within node_min_size..node_max_size. Under autoscaling this is the starting count; the cluster autoscaler then varies it within the min/max bounds."
}

variable "node_min_size" {
  type        = number
  default     = 2
  description = "Minimum number of nodes the cluster autoscaler may scale the managed node pool down to."
}

variable "node_max_size" {
  type        = number
  default     = 3
  description = "Maximum number of nodes the cluster autoscaler may scale the managed node pool up to."
}

variable "node_max_pods" {
  type        = number
  default     = 15
  description = "Maximum pods per node in the managed (default) node pool (10-250). With CNI overlay, pods draw IPs from pod_cidr instead of the subnet, so this is purely a scheduling density knob; size it against per-pod CPU/memory requests."
}

variable "pod_cidr" {
  type        = string
  default     = "100.64.0.0/18"
  description = "Private CIDR pods draw IPs from under CNI overlay; /18 = 64 node slices, expandable later. Must not overlap the VNet, peered/on-prem ranges reachable from it (check effective routes; note Tailscale uses 100.64.0.0/10), or the service CIDR. Immutable once applied: changing it forces cluster recreation, so verify the range against the customer's reachable routes before first provision."
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

