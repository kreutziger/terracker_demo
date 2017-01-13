provider "aws" {
	region = "eu-central-1"
}

variable "availability_zone" {
	description = "AZ to use"
	default = "eu-central-1a"
}

variable "environment" {
	description = "Environment of setup"
}

variable "instances" {
	description = "Instances of nginx to create"
}

variable "service" {
	description = "Service of setup"
}

variable "base_vpc_cidr" {
	description = "IP range of vpc"
}

variable "demo_ami" {
	description = "Packer generated AMI for the instances"
}

variable "demo_instance_type" {
	description = "Instance type"
	default = "t2.small"
}
