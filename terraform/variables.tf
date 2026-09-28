variable "location" {
  type    = string
  default = "us-central1"
}

# -------------------------------------------------------------------------------
# Core Environment & Project Variables
# -------------------------------------------------------------------------------
variable "project_id" {
  description = "The GCP project ID where resources will be provisioned."
  type        = string
}

variable "region" {
  description = "Primary GCP region for regional resources (subnets, Spanner, buckets)."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Common resource labels to attach to all supported resources."
  type        = map(string)
  default     = {}
}

# -------------------------------------------------------------------------------
# Networking Configuration
# -------------------------------------------------------------------------------
variable "vpc_name" {
  description = "The name of the custom VPC network."
  type        = string
  default     = "vpc"
}

variable "vpc_subnet_cidr" {
  description = "CIDR range for the primary VPC subnetwork."
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnetwork where Dataflow workers run."
  type        = string
  default     = "vpc-subnet"
}

# -------------------------------------------------------------------------------
# Cloud Spanner Configuration
# -------------------------------------------------------------------------------
variable "spanner_instance_name" {
  description = "Identifier for the Cloud Spanner instance."
  type        = string
  default     = "spanner-instance"
}

variable "spanner_config" {
  description = "Instance configuration defining regional or multi-regional topology."
  type        = string
  default     = "regional-us-central1"
}

variable "spanner_num_nodes" {
  description = "Number of compute nodes allocated to the Spanner instance."
  type        = number
  default     = 1
}

variable "spanner_edition" {
  description = "Edition of Cloud Spanner (e.g., STANDARD, ENTERPRISE)."
  type        = string
  default     = "STANDARD"
}

variable "spanner_default_backup_schedule_type" {
  description = "Default backup schedule type for Spanner databases."
  type        = string
  default     = "AUTOMATIC"
}

variable "spanner_databases" {
  description = "List of Spanner database definitions with retention and schema DDLs."
  type = list(object({
    name                     = string
    version_retention_period = optional(string, "3d")
    ddl                      = list(string)
    deletion_protection      = optional(bool, true)
  }))
}

# -------------------------------------------------------------------------------
# Cloud Storage Configuration
# -------------------------------------------------------------------------------
variable "destination_bucket_name" {
  description = "Globally unique bucket name for exported CDC text output."
  type        = string
}

variable "dataflow_temp_bucket_name" {
  description = "Globally unique bucket name for Dataflow staging and temp files."
  type        = string
}

variable "gcs_cors_rules" {
  description = "CORS settings applied to the CDC output bucket."
  type = list(object({
    origin          = list(string)
    max_age_seconds = number
    method          = list(string)
    response_header = list(string)
  }))
  default = []
}

variable "force_destroy_buckets" {
  description = "Safety switch for GCS buckets; keep false in production environments."
  type        = bool
  default     = false
}

# -------------------------------------------------------------------------------
# Dataflow Pipeline Configuration
# -------------------------------------------------------------------------------
variable "enable_dataflow_job" {
  description = "Control flag to deploy or suppress automatic Dataflow job execution."
  type        = bool
  default     = false
}

variable "dataflow_job_name" {
  description = "Name assigned to the Dataflow job."
  type        = string
  default     = "spanner-to-gcs"
}

variable "dataflow_service_account_id" {
  description = "Account ID for the custom Dataflow worker service account."
  type        = string
  default     = "dataflow-cdc-sa"
}

variable "dataflow_template_gcs_path" {
  description = "GCS path to the Dataflow Flex or classic template."
  type        = string
  default     = "gs://dataflow-templates-us-central1/latest/Spanner_to_GCS_Text"
}

variable "dataflow_source_table" {
  description = "Cloud Spanner table name to extract."
  type        = string
}

variable "dataflow_source_database" {
  description = "Cloud Spanner database ID containing the target table."
  type        = string
}

variable "dataflow_additional_experiments" {
  description = "List of experimental flags enabled for the Dataflow pipeline runtime."
  type        = list(string)
  default     = ["enable_preflight_validation"]
}