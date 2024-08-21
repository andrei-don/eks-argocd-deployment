locals {
  tags = {
    project_name = var.project_name
  }
  az_number = length(data.aws_availability_zones.main.names)
}