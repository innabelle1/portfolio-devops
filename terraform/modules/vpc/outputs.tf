output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
