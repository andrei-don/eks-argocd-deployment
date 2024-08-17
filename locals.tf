locals {
  tags = {
    project_name = "EKS-playground"
  }
  az_number = length(data.aws_availability_zones.main.names)
}