variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = false
}

#variable "private_subnet_cidrs" {
 # type        = list(string)
  #description = "List of CIDRs for private subnets"
#}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for public subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

#variable "enable_dns_support" {
 # description = "Enable DNS support"
  #type        = bool
  #default     = true
#}

#variable "enable_dns_hostnames" {
 # description = "Enable DNS hostnames"
  #type        = bool
  #default     = true
#}
