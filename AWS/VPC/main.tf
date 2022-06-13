// Provider configuration
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">= 4.7.0"
   }
 }
}
 
provider "aws" {
 region = "us-east-2"
}

variable "cidr_block" {
    type    = string
    default = "10.0.0.0/16"
}

module "vpc" {
    //name = "lucasnet-useast-2"
    source = "terraform-aws-modules/vpc/aws"
    //cidr_block = var.cidr_block

}
/* 
 resource "aws_instance" "openvpn-1" {
     
    ami           = "unknown"
    instance_type = "unknown"

 }
 */