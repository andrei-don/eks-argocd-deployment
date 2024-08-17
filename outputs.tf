output "az-names" {
  value = length(data.aws_availability_zones.main.names)
}