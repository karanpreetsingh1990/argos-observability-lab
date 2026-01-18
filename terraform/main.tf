provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }

}

provider "kubernetes" {
  config_path = "~/.kube/config"

}

resource "helm_release" "haproxy" {
  count            = var.install_haproxy == true ? 1 : 0
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


resource "helm_release" "metrics-server" {
  count      = var.install_metrics_server == true ? 1 : 0
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  name       = "metrics-server"
  chart      = "metrics-server"
  #namespace  = "kube-system"
  set = [{
    name  = "args"
    value = "{--kubelet-insecure-tls=true}"
  }]
}


## New Relic module

module "newrelic" {
  count            = var.install_newrelic_k8s == true ? 1 : 0
  source           = "./modules/newrelic"
  newrelic_options = var.newrelic_options
  newrelic_key     = var.newrelic_key
}


## Datadog related config


module "datadog" {
  count       = var.install_datadog_k8s == true ? 1 : 0
  source      = "./modules/datadog"
  datadog_key = var.datadog_key
}
