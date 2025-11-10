variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets for the ALB"
  type        = list(string)
}


variable "target_group_port" {
  description = "Port on which the backend targets listen (NGINX)"
  type        = number
  default     = 80
}
variable "rev_proxy_sg_id" {}
variable "private_subnets" {
  description = "List of private subnets for the ALB"
  type        = list(string)
}
variable "public_instance_ids" {
  description = "List of public instance IDs running NGINX"
  type        = list(string)
}
variable "private_instance_ids" {
  description = "List of private instance IDs running the Flask app"
  type        = list(string)
}

