# Cloud Spanner 
module "spanner" {
  source                       = "./modules/cloud-spanner"
  name                         = "spanner-instance"
  config                       = "regional-us-central1"
  display_name                 = "spanner-instance"
  num_nodes                    = 1
  edition                      = "STANDARD"
  default_backup_schedule_type = "AUTOMATIC"
  labels = {
    "foo" = "bar"
  }
  databases = [
    {
      name                     = "cdc-db"
      version_retention_period = "3d"
      ddl = [
        "CREATE TABLE users (id INT64 NOT NULL PRIMARY KEY,name STRING(1024),email STRING(1024),city STRING(1024))"
      ]
      deletion_protection = false
    }
  ]
}

# GCS
module "destination_bucket" {
  source   = "./modules/gcs"
  location = var.location
  name     = "spanner-cdc-bucket"
  cors = [
    {
      origin          = ["*"]
      max_age_seconds = 3600
      method          = ["GET", "POST", "PUT", "DELETE"]
      response_header = ["*"]
    }
  ]
  versioning                  = true
  force_destroy               = true
  uniform_bucket_level_access = true
}