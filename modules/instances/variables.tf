variable "public_instance_type" {
  default = "t2.micro"
}
variable "private_instance_type" {
  default = "t2.micro"
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "public_instance_sg_id" {}
variable "key_pair_name" {
  description = "Name of the SSH key pair"
}
variable "public_key_path" {
  description = "Path to the public key file"
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "private_instance_sg_id" {}
variable "private_key_path" {}
variable "private_alb_dns_name" {

}
