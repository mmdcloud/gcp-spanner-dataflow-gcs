variable "location" {
  type    = string
  default = "us-central1"
}

variable "vpc_subnet_cidr" {
  description = "CIDR range for the vpc subnet."
  type        = string
  default     = "10.1.0.0/24"
}