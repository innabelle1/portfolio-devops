# AWS region
variable "region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

# SSH
#variable "ssh_key_name" {
# description = "Name of the existing EC2 Key Pair for SSH"
# type        = string
#}

#variable "public_subnet_cidrs" {
 # description = "List of public subnet CIDRs"
 #type        = list(string)
#}

# Project metadata
variable "project_name" {
  description = "Project name to tag resources"
  type        = string
  default     = "spring-petclinic"
}

variable "key_name" {
  description = "SSH key name for Bastion"
  type        = string
}

# Environment (dev, staging, prod)
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# EKS cluster
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "spring-petclinic-eks"
}

# user arn
variable "principal_arn" {
  type        = string
  description = "ARN of IAM user to grant access to EKS"
}

# user name
variable "iam_user_name" {
  type        = string
  description = "Username of IAM user"
}

# Node Role ARN
#variable "node_role_arn" {
# description = "IAM Role ARN for EKS Node Group"
#type        = string
#}

# VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# VPC CIDR for EKS cluster
variable "cluster_service_cidr" {
  description = "Cluster service CIDR for EKS cluster and node bootstrap"
  type        = string
  default     = "10.100.0.0/16" # или твой сервисный CIDR
}

 #Private subnet CIDR
#variable "private_subnet_cidrs" {
 #description = "List of CIDR blocks for private subnets"
#type        = list(string)
# default     = ["10.0.1.0/24", "10.0.2.0/24"]
#}

#Public subnet CIDR
  variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ECR repository
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "petclinic/customers-service"
}
