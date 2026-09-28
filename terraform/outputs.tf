output "temp_gcs_location" {
  value = "gs://${module.dataflow_temp_bucket.bucket_name}/temp"
}

output "dataflow_service_account" {
  value = google_service_account.dataflow_service_account.email
}

output "subnetwork" {
  value = module.vpc.subnet_self_links["vpc-subnet"]
}

output "spanner_instance_id" {
  value = module.spanner.spanner_instance_id
}

output "destination_bucket" {
  value = "gs://${module.destination_bucket.bucket_name}/"
}