variable "aws_region" {
  description = "AWS Region"
  default     = "ap-southeast-3"
}

variable "region" {
  default = "ap-southeast-3"
}

variable "access" {
  default = ""
}
variable "secret" {
  default = ""
}

// Tag
variable "birthday" {
  default = "13-08-2023"
}
variable "environment" {
  default = "developmentlab2"
}
variable "Backup" {
  default = "BackupDaily"
}
variable "project" {
  default = "lab" #CHANGE
}

variable "cidr" {
  default = "172.50.0.0/16" #CHANGE
}
variable "Public_Subnet_AZ1" {
  default = "172.50.11.0/24" #CHANGE
}
variable "Public_Subnet_AZ2" {
  default = "172.50.12.0/24" #CHANGE
}
variable "Private_APP_AZ1" {
  default = "172.50.21.0/24" #CHANGE
}
variable "Private_APP_AZ2" {
  default = "172.50.22.0/24" #CHANGE
}
variable "Private_Intra_AZ1" {
  default = "172.50.31.0/24" #CHANGE
}
variable "Private_Intra_AZ2" {
  default = "172.50.32.0/24" #CHANGE
}

variable "amazonlinux" {
  default = ""
}

variable "gateway" {
  type = map(any)
  default = {
    "ssh" = 22
  }
}

variable "mongodb" {
  type = map(any)
  default = {
    "ssh"     = 22
  }
}


locals {
  common_tags = {
    Birthday         = var.birthday
    Environment      = var.environment == "" ? "Development" : "Production"
  }
}