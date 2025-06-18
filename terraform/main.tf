# Project settings
data "google_project" "project" {}

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

# Create Cloud Storage bucket for Dataflow temp files if it doesn't exist
resource "google_storage_bucket" "dataflow_temp_bucket" {
  name          = "madmax-dataflow-temp-bucket"
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true
}

# Service account for Dataflow jobs
resource "google_service_account" "dataflow_service_account" {
  account_id   = "dataflow-cdc-sa"
  display_name = "Dataflow CDC Service Account"
}

# Grant necessary permissions to the service account
resource "google_project_iam_member" "dataflow_worker" {
  project = data.google_project.project.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = data.google_project.project.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "spanner_reader" {
  project = data.google_project.project.project_id
  role    = "roles/spanner.databaseReader"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

module "spanner_to_gcs_cdc" {
  source                = "./modules/dataflow"
  name                  = "spanner-to-gcs"
  template_gcs_path     = "gs://dataflow-templates-us-central1/latest/Spanner_to_GCS_Text"
  temp_gcs_location     = "gs://${google_storage_bucket.dataflow_temp_bucket.name}/temp"
  service_account_email = google_service_account.dataflow_service_account.email
  parameters = {
    spannerTable      = "users"
    spannerProjectId  = "${data.google_project.project.project_id}"
    spannerInstanceId = module.spanner.spanner_instance_id
    spannerDatabaseId = "cdc-db"
    textWritePrefix   = "gs://${module.destination_bucket.bucket_name}/"
  }
}