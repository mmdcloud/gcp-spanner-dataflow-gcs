variable "name"{}
variable "template_gcs_path"{}
variable "temp_gcs_location"{}
variable "service_account_email"{}
variable "parameters" {
  type = map(string)
    default = {}
}