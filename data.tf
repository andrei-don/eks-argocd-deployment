data "aws_availability_zones" "main" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}