variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block subnet1"
  type        = string
  default     = "10.0.0.0/27"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block subnet2"
  type        = string
  default     = "10.0.0.32/27"
}

variable "instance_type" {
  description = "tipo"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI"
  type        = string
  default     = "ami-02141377eee7defb9"
}

variable "domain_name" {
  description = "El nombre del dominio registrado en Route 53"
  type        = string
  default     = "rodrigofernandezbravo.com"
}