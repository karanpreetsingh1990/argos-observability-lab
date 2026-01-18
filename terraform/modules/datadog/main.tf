resource "kubernetes_secret_v1" "datadog-api-key" {
  metadata {
    name = "datadog-secret"
  }
  data = {
    api-key = var.datadog_key
  }
  type = "generic"

}

resource "helm_release" "datadog_k8s" {
  depends_on = [kubernetes_secret_v1.datadog-api-key]
  repository = "https://helm.datadoghq.com"
  name       = "datadog"
  chart      = "datadog-operator"

  provisioner "local-exec" {
    when    = create
    command = "kubectl apply -f datadog-agent.yml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f datadog-agent.yml"

  }
}
