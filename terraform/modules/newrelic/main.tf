## New Relic related config

locals {
  set_expression = [
    for k, v in var.newrelic_options : {
      name  = k
      value = v
    }
  ]
  key_var = {
    "name"  = "global.licenseKey"
    "value" = var.newrelic_key
  }
  set_with_key = concat(local.set_expression, [local.key_var])
}

resource "helm_release" "newrelic-k8s" {
  repository       = "https://helm-charts.newrelic.com"
  name             = "newrelic"
  chart            = "nri-bundle"
  namespace        = "newrelic"
  create_namespace = true
  set              = local.set_with_key
}
