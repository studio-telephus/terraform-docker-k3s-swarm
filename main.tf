data "tls_public_key" "swarm_public_key" {
  private_key_pem = base64decode(var.swarm_private_key)
}

locals {
  container_mount_dirs = [
    "${path.module}/filesystem-shared-ca-certificates",
    "${path.module}/filesystem",
  ]
  username       = "root"
  container_exec = "/mnt/install.sh"
  container_environment = {
    SSH_AUTHORIZED_KEYS = base64encode(data.tls_public_key.swarm_public_key.public_key_openssh)
  }
  containers_server = [for i, item in var.containers_server : {
    name         = item.name
    network_name = var.network_name
    ipv4_address = item.ipv4_address
    mount_dirs   = local.container_mount_dirs
    environment  = local.container_environment
    exec         = local.container_exec
    privileged   = false
  }]
  containers_worker = [for i, item in var.containers_worker : {
    name         = item.name
    network_name = var.network_name
    ipv4_address = item.ipv4_address
    mount_dirs   = local.container_mount_dirs
    environment  = local.container_environment
    exec         = local.container_exec
    privileged   = false
  }]
  worker_labels = merge(var.worker_labels, {
    "node.kubernetes.io/pool" = "worker-pool"
  })
  server_labels = length(var.containers_worker) > 0 ? merge(var.server_labels, {
    "node.kubernetes.io/type" = "master"
    }) : merge(var.server_labels, {
    "node.kubernetes.io/type" = "master"
  }, local.worker_labels)
}

module "docker_swarm" {
  source       = "github.com/studio-telephus/terraform-docker-swarm.git?ref=main"
  image        = var.image
  containers   = concat(local.containers_server, local.containers_worker)
  restart      = var.restart
  exec_enabled = var.exec_enabled
}

resource "time_sleep" "wait_for_docker_swarm" {
  depends_on = [
    module.docker_swarm
  ]
  create_duration = "5s"
}

module "k3s" {
  source               = "xunleii/k3s/module"
  k3s_version          = var.k3s_version
  cluster_domain       = var.cluster_domain
  k3s_install_env_vars = var.k3s_install_env_vars
  global_flags         = var.global_flags
  drain_timeout        = var.drain_timeout
  managed_fields       = var.managed_fields
  use_sudo             = var.use_sudo
  cidr = {
    pods     = var.cidr_pods
    services = var.cidr_services
  }
  servers = {
    for i, item in var.containers_server : "server-${i}" => {
      ip = item.ipv4_address
      connection = {
        user        = local.username
        host        = item.ipv4_address
        private_key = trimspace(base64decode(var.swarm_private_key))
        timeout     = var.node_connection_timeout
      }
      flags  = var.server_flags
      labels = local.server_labels
      annotations = {
        "server.index" : i
      }
    }
  }
  agents = {
    for i, item in var.containers_worker : "agent-${i}" => {
      ip = item.ipv4_address
      connection = {
        user        = local.username
        host        = item.ipv4_address
        private_key = trimspace(base64decode(var.swarm_private_key))
        timeout     = var.node_connection_timeout
      }
      labels = local.worker_labels
      annotations = {
        "worker.index" : i
      }
    }
  }
  depends_on_ = time_sleep.wait_for_docker_swarm
  depends_on  = [time_sleep.wait_for_docker_swarm]
}
