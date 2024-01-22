data "tls_public_key" "swarm_public_key" {
  private_key_pem = base64decode(var.swarm_private_key)
}

locals {
  container_mount_dirs = [
    "${path.module}/filesystem-shared-ca-certificates",
    "${path.module}/filesystem",
  ]
  container_exec = "/mnt/install.sh"
  container_environment = {
    SSH_AUTHORIZED_KEYS = base64encode(data.tls_public_key.swarm_public_key.public_key_openssh)
  }
  servers = [for i, item in var.servers : {
    name         = item.name
    network_name = var.network_name
    ipv4_address = item.ipv4_address
    mount_dirs   = local.container_mount_dirs
    environment  = local.container_environment
    exec         = local.container_exec
    privileged   = true
    entrypoint   = []
  }]
}

data "docker_image" "docker_ubuntu_systemd" {
  name = "eniocarboni/docker-ubuntu-systemd:22.04"
}

module "docker_swarm" {
  source       = "github.com/studio-telephus/terraform-docker-swarm.git?ref=main"
  image        = data.docker_image.docker_ubuntu_systemd
  containers   = local.servers
  restart      = var.restart
  exec_enabled = true
}
