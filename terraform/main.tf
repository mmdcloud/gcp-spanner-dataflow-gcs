data "google_project" "project" {
  project_id = var.project_id
}

# -------------------------------------------------------------------------------
# VPC Configuration
# -------------------------------------------------------------------------------
module "vpc" {
  source                          = "./modules/vpc"
  vpc_name                        = var.vpc_name
  delete_default_routes_on_create = false
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  subnets = [
    {
      name                     = var.subnet_name
      region                   = var.region
      purpose                  = "PRIVATE"
      role                     = "ACTIVE"
      private_ip_google_access = true
      ip_cidr_range            = var.vpc_subnet_cidr
    }
  ]
  firewall_data = []
}

# -------------------------------------------------------------------------------
# Cloud Spanner 
# -------------------------------------------------------------------------------
module "spanner" {
  source                       = "./modules/cloud-spanner"
  name                         = var.spanner_instance_name
  config                       = var.spanner_config
  display_name                 = var.spanner_instance_name
  num_nodes                    = var.spanner_num_nodes
  edition                      = var.spanner_edition
  default_backup_schedule_type = var.spanner_default_backup_schedule_type
  labels                       = var.labels
  databases                    = var.spanner_databases
}

# -------------------------------------------------------------------------------
# GCS Buckets
# -------------------------------------------------------------------------------
module "destination_bucket" {
  source                      = "./modules/gcs"
  project_id                  = var.project_id
  location                    = var.region
  name                        = var.destination_bucket_name
  cors                        = var.gcs_cors_rules
  versioning                  = true
  force_destroy               = var.force_destroy_buckets
  uniform_bucket_level_access = true
}

module "dataflow_temp_bucket" {
  source                      = "./modules/gcs"
  project_id                  = var.project_id
  location                    = var.region
  name                        = var.dataflow_temp_bucket_name
  cors                        = []
  force_destroy               = var.force_destroy_buckets
  uniform_bucket_level_access = true
}

# -------------------------------------------------------------------------------
# Service Account and IAM Roles
# -------------------------------------------------------------------------------
resource "google_service_account" "dataflow_service_account" {
  project      = var.project_id
  account_id   = var.dataflow_service_account_id
  display_name = "Dataflow CDC Service Account"
}

resource "google_project_iam_member" "dataflow_worker" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "spanner_reader" {
  project = var.project_id
  role    = "roles/spanner.databaseReader"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

# -------------------------------------------------------------------------------
# Dataflow Job (Execution controlled via var.enable_dataflow_job)
# -------------------------------------------------------------------------------
module "spanner_to_gcs_cdc" {
  count                 = var.enable_dataflow_job ? 1 : 0
  source                = "./modules/dataflow"
  name                  = var.dataflow_job_name
  template_gcs_path     = var.dataflow_template_gcs_path
  temp_gcs_location     = "gs://${module.dataflow_temp_bucket.bucket_name}/temp"
  service_account_email = google_service_account.dataflow_service_account.email
  network               = module.vpc.vpc_id
  subnetwork            = module.vpc.subnet_self_links[var.subnet_name]
  parameters = {
    spannerTable      = var.dataflow_source_table
    spannerProjectId  = var.project_id
    spannerInstanceId = module.spanner.spanner_instance_id
    spannerDatabaseId = var.dataflow_source_database
    textWritePrefix   = "gs://${module.destination_bucket.bucket_name}/"
  }
  additional_experiments = var.dataflow_additional_experiments
}