# CDC Pipeline: Cloud Spanner to GCS via Dataflow

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)

A Terraform implementation of a Change Data Capture (CDC) pipeline that captures changes from Google Cloud Spanner, processes them using Dataflow, and stores the results in Google Cloud Storage (GCS).

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Cloud Spanner  │────>│    Dataflow     │────>│       GCS       │
│   (Source)      │     │ (CDC Pipeline)  │     │  (Destination)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Features

- Real-time Change Data Capture from Cloud Spanner
- Scalable data processing with Dataflow
- Configurable output formats (JSON, Avro, Parquet)
- Partition strategy for efficient GCS storage
- Infrastructure as Code with Terraform
- Monitoring and alerting setup

## Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform v1.0.0+
- Required GCP APIs enabled:
  - Cloud Spanner API
  - Dataflow API
  - Storage API
  - IAM API

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/spanner-cdc-pipeline.git
cd spanner-cdc-pipeline
```

### 2. Set up your GCP credentials

```bash
gcloud auth application-default login
```

### 3. Update the configuration

Create a `terraform.tfvars` file:

```hcl
project_id           = "your-project-id"
region               = "us-central1"
spanner_instance     = "my-spanner-instance"
spanner_database     = "my-database"
watched_tables       = ["users", "orders", "products"]
gcs_bucket_name      = "my-cdc-destination-bucket"
output_format        = "AVRO"  # Options: JSON, AVRO, PARQUET
dataflow_temp_bucket = "my-dataflow-temp-bucket"
```

### 4. Initialize and apply Terraform

```bash
terraform init
terraform apply
```

## Components

### Cloud Spanner

The source database where changes are tracked. The Terraform configuration:
- Sets up a Spanner instance (or uses an existing one)
- Configures the database for CDC capabilities
- Creates appropriate IAM permissions

### Dataflow

Processes the CDC events in real-time:
- Uses a predefined CDC template
- Handles transformation and enrichment
- Manages schema evolution
- Provides monitoring and error handling

### Google Cloud Storage (GCS)

Destination for the processed data:
- Configures bucket with appropriate lifecycle policies
- Sets up directory structure for partitioned data
- Manages access controls

## Advanced Configuration

### Partition Strategy

Configure how data is partitioned in GCS:

```hcl
partition_strategy = {
  type          = "time"
  time_format   = "YYYY/MM/DD/HH"
  include_table = true
}
```

### Schema Evolution

Handle schema changes gracefully:

```hcl
schema_evolution_mode = "COMPATIBLE"  # Options: STRICT, COMPATIBLE, PERMISSIVE
```

### Monitoring

Configure monitoring and alerting:

```hcl
enable_monitoring = true
alert_email       = "alerts@yourdomain.com"
```

## Directory Structure

```
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables
├── outputs.tf             # Output values
├── spanner.tf             # Spanner-specific configuration
├── dataflow.tf            # Dataflow job configuration
├── storage.tf             # GCS bucket configuration
├── monitoring.tf          # Monitoring and alerting
├── iam.tf                 # IAM permissions
├── README.md              # This file
└── examples/              # Example configurations
    └── basic/             # Basic implementation example
    └── advanced/          # Advanced configuration example
```

## Usage Examples

### Capture changes from specific tables

```hcl
watched_tables = ["users", "transactions"]
table_schemas = {
  users = {
    include_columns = ["id", "name", "email", "updated_at"]
    exclude_columns = ["password_hash"]
  }
  transactions = {
    include_columns = ["*"]
    exclude_columns = ["internal_metadata"]
  }
}
```

### Data transformations

```hcl
transformations = [
  {
    type      = "mask"
    table     = "users"
    column    = "email"
    pattern   = "(.*)@(.*)"
    replacement = "****@$2"
  }
]
```

## Troubleshooting

### Common issues

1. **Permission errors**: Ensure your service account has the necessary permissions
2. **Dataflow job failures**: Check the job logs in Cloud Console
3. **Schema mismatch errors**: Verify your schema evolution configuration

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ by Your DevOps Team
