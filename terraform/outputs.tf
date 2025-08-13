output "destination_bucket" {
    value = module.destination_bucket.bucket_name
}

output "spanner_source_id" {
    value = module.spanner.spanner_instance_id
}