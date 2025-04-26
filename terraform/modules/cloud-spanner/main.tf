resource "google_spanner_instance" "spanner_instance" {
  name                         = "spanner-instance"
  config                       = "regional-us-central1"
  display_name                 = "spanner-instance"
  num_nodes                    = 1
  edition                      = "STANDARD"
  default_backup_schedule_type = "AUTOMATIC"
  labels = {
    "foo" = "bar"
  }
}

resource "google_spanner_database" "database" {
  instance                 = google_spanner_instance.spanner_instance.name
  name                     = "my-db"
  version_retention_period = "3d"
  ddl = [
    "CREATE TABLE t1 (t1 INT64 NOT NULL,) PRIMARY KEY(t1)",
    "CREATE TABLE t2 (t2 INT64 NOT NULL,) PRIMARY KEY(t2)",
  ]
  deletion_protection = false
}