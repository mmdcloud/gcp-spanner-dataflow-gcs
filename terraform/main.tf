# Cloud Spanner 
module "spanner" {
  source   = "./modules/spanner"
  name     = "spanner"
  instance = "spanner-instance"
  database = "spanner-database"
  location = var.location
  nodes    = 1
}

# GCS
module "destination_bucket" {
  source   = "./modules/gcs"
  location = var.location
  name     = "spanner-cdc-bucket"
  cors = [
    {
      origin          = ["http://${module.carshub_frontend_service_lb.ip_address}"]
      max_age_seconds = 3600
      method          = ["GET", "POST", "PUT", "DELETE"]
      response_header = ["*"]
    }
  ]
  versioning = true  
  force_destroy               = true
  uniform_bucket_level_access = true
}