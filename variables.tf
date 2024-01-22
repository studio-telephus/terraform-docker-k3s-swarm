variable "cluster_domain" {
  type    = string
  default = "cluster.local"
}

variable "k3s_version" {
  type    = string
  default = "v1.28.5+k3s1"
}

variable "swarm_private_key" {
  type        = string
  description = "Base64 encoded private key PEM."
  sensitive   = true
}

variable "cidr_pods" {
  type = string
}

variable "cidr_services" {
  type = string
}

variable "k3s_install_env_vars" {
  type    = map(any)
  default = {}
}

variable "global_flags" {
  type    = list(string)
  default = []
}

variable "server_flags" {
  type    = list(string)
  default = []
}

variable "server_labels" {
  type    = map(string)
  default = {}
}

variable "worker_labels" {
  type = map(string)
  default = {
  }
}

variable "managed_fields" {
  type    = list(string)
  default = ["label", "taint", "annotation"]
}

variable "use_sudo" {
  type        = bool
  description = "Whether or not to use kubectl with sudo during cluster setup."
  default     = false
}

variable "drain_timeout" {
  type    = string
  default = "60s"
}

variable "containers_server" {
  type = list(object({
    name         = string
    ipv4_address = string
  }))
}

variable "containers_worker" {
  type = list(object({
    name         = string
    ipv4_address = string
  }))
  default = []
}

variable "network_name" {
  type = string
}

variable "restart" {
  type = string
}

variable "exec_enabled" {
  type    = bool
  default = true
}

variable "image" {
  type = string
}

variable "node_connection_timeout" {
  default = "60s"
}
