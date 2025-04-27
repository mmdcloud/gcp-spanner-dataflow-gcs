resource "google_spanner_instance" "spanner_instance" {
  name                         = var.name
  config                       = var.config
  display_name                 = var.display_name
  num_nodes                    = var.num_nodes
  edition                      = var.edition
  default_backup_schedule_type = var.default_backup_schedule_type
  labels                       = var.labels
}

resource "google_spanner_database" "database" {
  instance                 = google_spanner_instance.spanner_instance.name
  count = length(var.databases)
  name                     = var.databases[count.index].name
  version_retention_period = var.databases[count.index].version_retention_period
  ddl = var.databases[count.index].ddl
  deletion_protection = var.databases[count.index].deletion_protection
}
