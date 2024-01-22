# terraform-docker-k3s-embedded

## HA with Embedded DB

The fourth method uses a true embedded etcd server, with no extra steps needed to setup a database. It is also ridiculously simple to set up. These benefits make it perfect for edge devices. The only downside to this method is that it is quorum-based, so you need three servers to maintain quorum. If quorum is lost you can always reset the etcd cluster back to a single node, and expand the cluster from there. While you still have to maintain a quorum during normal operation, you won’t lose your cluster in the case of quorum loss.
