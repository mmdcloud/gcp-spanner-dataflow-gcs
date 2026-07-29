resource "google_dataflow_job" "job" {
  name                    = var.name
  template_gcs_path       = var.template_gcs_path
  temp_gcs_location       = var.temp_gcs_location
  network = var.network
  subnetwork = var.subnetwork
  service_account_email   = var.service_account_email
  additional_experiments = var.additional_experiments
  parameters = var.parameters
}