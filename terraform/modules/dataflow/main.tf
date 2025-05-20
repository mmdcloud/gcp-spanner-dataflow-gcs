resource "google_dataflow_job" "job" {
  name                    = var.name
  template_gcs_path       = var.template_gcs_path
  temp_gcs_location       = var.temp_gcs_location
  service_account_email   = var.service_account_email
  parameters = var.parameters
}