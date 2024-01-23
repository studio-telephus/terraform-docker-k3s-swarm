variable "swarm_private_key" {
  type        = string
  description = "Base64 encoded private key PEM."
  sensitive   = true
}

variable "containers" {
  type = list(object({
    name         = string
    ipv4_address = string
  }))
}

variable "network_name" {
  type = string
}

variable "restart" {
  type = string
}
