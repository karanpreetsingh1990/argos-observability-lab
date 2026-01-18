## This file should not be committed to source control. It's being added to provide a reference of values to be passed
install_haproxy        = true
install_metrics_server = true
install_newrelic_k8s   = false
install_datadog_k8s    = false
newrelic_key           = "<new relic license key>"
newrelic_options = {
  "global.lowDataMode"                                                      = "true"
  "kubeEvents.enabled"                                                      = "true"
  "logging.enabled"                                                         = "true"
  "newrelic-logging.lowDataMode"                                            = "true"
  "k8s-agents-operator.enabled"                                             = "true"
  "global.cluster"                                                          = "argus"
  "newrelic-prometheus-agent.enabled"                                       = "true"
  "newrelic-prometheus-agent.lowDataMode"                                   = "true"
  "newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled" = "false"
}
datadog_key = "<datadog api key>"
