variable "cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"
}

variable "flow-logs" {
  type        = bool
  description = "Enable VPC Flow Logs"
  default     = true
}

variable "vpc-name" {
  type        = string
  description = "VPC Name on tag"
  default     = false
}

variable "log-group-name" {
  type        = string
  description = "Log Group Destination Flow Log"
  default     = false
}

variable "kms-arn" {
  type = string
  description = "KMS CMK ARN for Loggroup"
}