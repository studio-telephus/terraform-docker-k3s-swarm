data "tls_public_key" "swarm_public_key" {
  private_key_pem = base64decode(var.swarm_private_key)
}

resource "docker_image" "swarm_image" {
  name         = "tel-debian-bookworm-systemd"
  keep_locally = false
  build {
    context = path.module
    build_args = {
      _SSH_AUTHORIZED_KEYS = base64encode(data.tls_public_key.swarm_public_key.public_key_openssh)
    }
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
  volumes      = var.volumes
  mounts       = var.mounts
}
