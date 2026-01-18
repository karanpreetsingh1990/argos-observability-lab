variable "http_node_port" {
  type    = string
  default = "30000"
}

variable "https_node_port" {
  type    = string
  default = "30001"
}

variable "stat_node_port" {
  type    = string
  default = "30002"
}

variable "prom_node_port" {
  type    = string
  default = "30003"
}

variable "install_haproxy" {
  type    = bool
  default = true
}

variable "install_metrics_server" {
  type    = bool
  default = false
}

variable "install_newrelic_k8s" {
  type    = bool
  default = false
}

variable "newrelic_key" {
  type      = string
  sensitive = true
}


variable "newrelic_options" {
  type = map(string)

}

variable "install_datadog_k8s" {
  type    = bool
  default = false
}

variable "datadog_key" {
  type      = string
  sensitive = true
}
