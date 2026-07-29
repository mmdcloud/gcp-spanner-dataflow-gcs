variable "name" {}
variable "network" {}
variable "subnetwork" {}
variable "template_gcs_path" {}
variable "temp_gcs_location" {}
variable "service_account_email" {}
variable "parameters" {
  type    = map(string)
  default = {}
}
variable "additional_experiments" {
  type    = list(string)
}
