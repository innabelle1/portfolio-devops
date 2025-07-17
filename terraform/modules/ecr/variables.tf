variable "services" {
  description = "List of microservices to create ECR repos for"
  type        = list(string)
}


#variable "repository_name" {
#  type        = string
#  description = "ECR repository name"
#}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
}

variable "encryption_type" {
  description = "Encryption type for ECR (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key" {
  description = "ARN of the KMS key for ECR encryption"
  type        = string
  default     = null
}
