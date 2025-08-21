variable "region" {
  type        = string
  description = "The region to deploy the EC2 instance."
}

variable "instance_type" {
  type        = string
  description = "the instance type you want to use."
}

variable "instance_ami" {
  type        = string
  description = "your instance ami ID."
}

variable "key_pair_name" {
  type = string
  description = "This is key created by vishal."
}