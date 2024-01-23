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
}

resource "docker_image" "docker_ubuntu_systemd" {
  name = "robertdebock/debian:bookworm"
}

module "docker_swarm_privileged" {
  source       = "github.com/studio-telephus/terraform-docker-swarm.git?ref=main"
  image        = docker_image.docker_ubuntu_systemd.image_id
  containers   = var.containers
  restart      = var.restart
  exec_enabled = true
  network_name = var.network_name
  mount_dirs   = local.container_mount_dirs
  environment  = local.container_environment
  exec         = local.container_exec
  privileged   = true
  entrypoint   = []
  volumes = [
    {
      container_path = "/sys/fs/cgroup"
      host_path      = "/sys/fs/cgroup"
      read_only      = true
      from_container = null
      volume_name    = null
    }
  ]
}
