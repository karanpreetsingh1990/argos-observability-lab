variable "newrelic_options" {
  type = map(string)

}

variable "newrelic_key" {
  type      = string
  sensitive = true
}
