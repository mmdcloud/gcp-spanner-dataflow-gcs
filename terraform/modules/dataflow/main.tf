resource "google_dataflow_job" "job" {
  name                         = var.name
  template_gcs_path            = var.template_gcs_path
  temp_gcs_location            = var.temp_gcs_location
  network                      = var.network
  subnetwork                   = var.subnetwork
  enable_streaming_engine      = var.enable_streaming_engine
  transform_name_mapping       = var.transform_name_mapping
  ip_configuration             = var.ip_configuration
  on_delete                    = var.on_delete
  machine_type                 = var.machine_type
  max_workers                  = var.max_workers
  kms_key_name                 = var.kms_key_name
  skip_wait_on_job_termination = var.skip_wait_on_job_termination
  labels                       = var.labels
  service_account_email        = var.service_account_email
  additional_experiments       = var.additional_experiments
  parameters                   = var.parameters
}

resource "google_dataflow_flex_template_job" "flex_job" {
  count                        = var.is_flex ? 1 : 0
  provider                     = google-beta
  temp_location                = var.temp_gcs_location
  name                         = var.name
  deletion_policy              = var.deletion_policy    
  ip_configuration             = var.ip_configuration
  enable_streaming_engine      = var.enable_streaming_engine
  transform_name_mapping       = var.transform_name_mapping
  on_delete                    = var.on_delete
  machine_type                 = var.machine_type
  max_workers                  = var.max_workers
  kms_key_name                 = var.kms_key_name
  skip_wait_on_job_termination = var.skip_wait_on_job_termination
  labels                       = var.labels
  num_workers                  = var.num_workers
  launcher_machine_type        = var.launcher_machine_type
  sdk_container_image          = var.sdk_container_image
  staging_location             = var.staging_location
  autoscaling_algorithm        = var.autoscaling_algorithm
  additional_pipeline_options  = var.additional_pipeline_options
  create_ignore_already_exists = var.create_ignore_already_exists
  network                      = var.network
  subnetwork                   = var.subnetwork
  service_account_email        = var.service_account_email
  container_spec_gcs_path      = var.container_spec_gcs_path
  additional_experiments       = var.additional_experiments
  parameters                   = var.parameters
}