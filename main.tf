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
  docker_image_name = "tel-debian-bookworm-systemd"
}

resource "docker_image" "swarm_image" {
  name         = local.docker_image_name
  keep_locally = false
  build {
    context = path.module
  }
  triggers = {
    dir_sha1 = sha1(join("", [
      filesha1("${path.module}/Dockerfile")
    ]))
  }
}

module "swarm_containers" {
  count      = length(var.containers)
  source     = "github.com/studio-telephus/terraform-docker-container.git?ref=1.0.3"
  name       = var.containers[count.index].name
  image      = docker_image.swarm_image.image_id
  restart    = var.restart
  privileged = true
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
