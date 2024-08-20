variable "region" {
  description = "Region used for the deployment."
  type        = string
  default     = "eu-west-1"
}

variable "cidr_block" {
  description = "CIDR block used by the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "newbits" {
  description = "Newbits argument to be used in the cidrsubnet() function."
  type        = number
  default     = 8
}

variable "public_subnet_count" {
  description = "The number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "The number of private subnets"
  type        = number
  default     = 3
}

variable "aws_route53_zone_id" {
  description = "The zone id for the R53 zone used for certificate validation"
  type        = string
}

variable "domain_name" {
  description = "The name of the domain for which you are creating the certificate"
  type        = string
}

variable "admin_arn" {
  description = "The ARN of the admin user that you want to grant access to the cluster."
  type        = string
}