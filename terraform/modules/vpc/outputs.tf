output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

#output "public_subnet_ids" {
 #description = "list of public"
 #value = module.vpc.public_subnet_ids
#}

#output "public_subnets" {
 # description = "List of public subnet IDs"
  #value       = module.vpc.public_subnets
#}
