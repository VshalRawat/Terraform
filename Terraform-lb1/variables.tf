variable "region" {
  type        = string
  description = "The region where you want to deploy the resources"
}

variable "instance_type" {
  type        = string
  description = "the instance type you want to use"
}

variable "instance_ami" {
  type        = string
  description = "your instance ami ID"
}

variable "bucket_name" {
  type        = string
  description = "the name of your buclet"
}