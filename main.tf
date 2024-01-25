data "tls_public_key" "swarm_public_key" {
  private_key_pem = base64decode(var.swarm_private_key)
}

locals {
  container_upload_dirs = [
    "${path.module}/filesystem-shared-ca-certificates",
    "${path.module}/filesystem",
  ]
  container_exec = "/mnt/install.sh"
  container_environment = {
    SSH_AUTHORIZED_KEYS = base64encode(data.tls_public_key.swarm_public_key.public_key_openssh)
  }
}

resource "docker_image" "docker_ubuntu_systemd" {
  name = "robertdebock/debian:bookworm"
}

module "swarm_containers" {
  count      = length(var.containers)
  source     = "github.com/studio-telephus/terraform-docker-container.git?ref=main"
  name       = var.containers[count.index].name
  image      = docker_image.docker_ubuntu_systemd.image_id
  restart    = var.restart
  privileged = true
  entrypoint = []
  networks_advanced = [
    {
      name         = var.network_name
      ipv4_address = var.containers[count.index].ipv4_address
    }
  ]
  upload_dirs  = local.container_upload_dirs
  exec_enabled = true
  exec         = local.container_exec
  volumes      = var.volumes
  mounts       = var.mounts
  environment  = local.container_environment
}
