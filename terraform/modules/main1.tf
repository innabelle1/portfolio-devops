terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC (local)
module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
}

resource "aws_security_group" "eks_node_group_sg" {
 name        = "${var.project_name}-node-group-sg"
  description = "Security group for EKS node group"
  vpc_id      = module.vpc.vpc_id

 # access to all egress connect (API server, Docker Hub)
  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

 # access ingresss trafic from Control Plane SG - Inbound - kubelet webhook от Control Plane
  ingress {
    description     = "Allow pods to communicate with the cluster API Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id] # <-- dynamic from module EKS
  }

  # Inbound - node connections
  ingress {
    description     = "Allow node-to-node communication"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  ingress {
    description     = "Allow node-to-node communication UDP"
    from_port       = 1025
    to_port         = 65535
    protocol        = "udp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  tags = {
    Name = "${var.project_name}-node-group-sg"  
  }
}

#data "aws_iam_policy_document" "node_assume_role_policy" {
 # statement {
  #  actions = ["sts:AssumeRole"]
   # principals {
    #  type        = "Service"
     # identifiers = ["ec2.amazonaws.com"]
   # }
  #}
#}

#resource "aws_iam_role" "node_role" {
 # name               = "eks-node-role"
  #assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
#}

#resource "aws_iam_role_policy_attachment" "node_role_attach" {
  #for_each = toset([
    #"arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
   # "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  #  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 # ])
  #role       = aws_iam_role.node_role.name
 # policy_arn = each.key
#}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
  
 cluster_name    = var.cluster_name
 cluster_version = "1.32"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  cluster_endpoint_public_access = true
  enable_irsa = true
  create_kms_key                = true
  kms_key_enable_default_policy = false

cluster_endpoint_public_access_cidrs = [
  "0.0.0.0/0"  # access to all
]

kms_key_administrators = [
    "arn:aws:iam::701173654142:user/admin"
]

cluster_addons = {
  coredns = {
    addon_version     = "v1.11.3-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
  kube-proxy = {
    addon_version     = "v1.31.7-eksbuild.7"
    resolve_conflicts = "OVERWRITE"
  }
  vpc-cni = {
    addon_version     = "v1.19.5-eksbuild.3"
    resolve_conflicts = "OVERWRITE"
  }
  eks-pod-identity-agent = {
    addon_version     = "v1.3.4-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
}


access_entries = {
    # One access entry with a policy associated
    admin_access = {
      principal_arn = "arn:aws:iam::701173654142:user/admin"

      policy_associations = {
        cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
          type       = "cluster" #full access to cluster
          }
        }
      }
    }
 }

eks_managed_node_groups = {
    example = {
      name = "node"
      desired_size = 1
      max_size     = 3
      min_size     = 1
      instance_types   = ["t3.micro"]
      disk_size      = 1  
#      iam_role_arn = aws_iam_role.node_role.arn

      subnet_ids = module.vpc.public_subnets    
      security_groups = [aws_security_group.eks_node_group_sg.id]

    tags = {
      Project     = var.project_name
      Environment = var.environment
}
  }

    #depends_on = [aws_iam_role.node_role]
}
#    depends_on = [aws_iam_role.node_role]
}

# ECR (local)
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  environment     = var.environment
}
