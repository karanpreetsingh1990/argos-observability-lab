provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }

}

resource "helm_release" "haproxy" {
  repository       = "https://haproxytech.github.io/helm-charts"
  name             = "haproxytech"
  chart            = "kubernetes-ingress"
  create_namespace = true
  namespace        = "haproxy-controller"
  set = [{
    name  = "controller.service.nodePorts.http"
    value = var.http_node_port
    },
    {
      name  = "controller.service.nodePorts.https"
      value = var.https_node_port
    },
    {
      name  = "controller.service.nodePorts.stat"
      value = var.stat_node_port
    },
    {
      name  = "controller.service.nodePorts.prometheus"
      value = var.prom_node_port
  }]
}
