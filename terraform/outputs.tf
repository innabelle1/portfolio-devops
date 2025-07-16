output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
 description = "list of public"
 value = module.vpc.public_subnet_ids
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "node_group_sg" {
  value = aws_security_group.node_group_sg.id
}

output "node_group_group_arn" {
  value = aws_iam_role.node_group.arn
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_controller_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_instance_profile" {
  value = aws_iam_instance_profile.karpenter_node_instance_profile.name
}

output "eks_node_group" {
  value = aws_iam_role.node_group.arn
}
output "iam_user_name" {
  description = "Name of the created IAM user"
  value       = aws_iam_user.this.name
}

output "iam_user_arn" {
  description = "ARN of the created IAM user"
  value       = aws_iam_user.this.arn
}
