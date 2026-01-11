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
    value = "30000"
    },
    {
      name  = "controller.service.nodePorts.https"
      value = "30001"
    },
    {
      name  = "controller.service.nodePorts.stat"
      value = "30002"
    },
    {
      name  = "controller.service.nodePorts.prometheus"
      value = "30003"
  }]
}
