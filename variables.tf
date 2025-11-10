variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}
variable "auth_profile" {
  description = "The profile to use for authentication"
  type        = string
  default     = "default"
}
variable "vpc_cidr_block" {}
variable "public_subnet_1_cidr_block" {}
variable "public_subnet_2_cidr_block" {}
variable "private_subnet_1_cidr_block" {}
variable "private_subnet_2_cidr_block" {}
variable "key_pair_name" {}
variable "public_key_path" {}
variable "private_key_path" {}
variable "public_instance_type" {}
variable "private_instance_type" {}
