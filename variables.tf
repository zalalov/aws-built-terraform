# AWS access key
variable aws_access_key {
  description = "AWS Access Key"
}

# AWS secret key
variable aws_secret_key {
  description = "AWS Secret Key"
}

# AWS keypair name
variable aws_keypair_name {
  description = "AWS keypair name"
}

# AWS region
variable "aws_region" {
  description = "AWS region"
}

# ubuntu-trusty-14.04 (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-2d39803a" # N.Virginia
    "us-west-1" = "ami-48db9d28" # N.California
    "us-west-2" = "ami-d732f0b7" # Oregon
    "eu-west-1" = "ami-ed82e39e" # Ireland
    "eu-central-1" = "ami-26c43149" # Frankfurt
    "ap-northeast-1" = "ami-a21529cc" # Tokyo
    "ap-northeast-2" = "ami-09dc1267" # Seoul
    "ap-southeast-1" = "ami-21d30f42" # Singapore
    "ap-southeast-2" = "ami-ba3e14d9" # Sydney
    "ap-south-1" = "ami-4a90fa25" # Mumbai
    "sa-east-1" = "ami-dc48dcb0" # São Paulo
  }
}

variable "aws_db_config" {
  default = {
    "id" = "provectus-test-db"
    "storage" = "5"
    "engine" = "postgres"
    "engine_version" = "9.5.2"
    "instance_class" = "db.t2.micro"
    "db_name" = "provectus"
    "username" = "provectus"
    "password" = "70YupGVJEb80fBwll64miQxGnHGE7qNa"
  }
}
