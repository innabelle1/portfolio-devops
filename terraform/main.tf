# --------------------
# Terraform & Providers
#---------------------
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

#------#
# VPC 
#------#
module "vpc" {
  source = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  environment         = var.environment

tags = {
    Name = "portfolio-vpc"
  }
}

#IGW
resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "portfolio-igw"
  }
}

# Route Table + Association
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "portfolio-public-rt"
  }
}

resource "aws_route_table_association" "public" {
 count = length(module.vpc.public_subnet_ids)
  subnet_id      = module.vpc.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

#---------------------------#
# IAM for System Node Group
#---------------------------#
data "aws_iam_policy_document" "node_assume" {
 statement {
  effect = "Allow"
actions = ["sts:AssumeRole"]
 principals {
   type        = "Service"
  identifiers = ["ec2.amazonaws.com"]
 }
}
}

# checkov:skip=CKV_AWS_273 "Demo only: IAM User for quick access in non-prod environment"
resource "aws_iam_user" "this" {
 name = var.iam_user_name

  tags = {
   Name        = var.iam_user_name
   Environment = var.environment
   ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "node_group" {

  name = "eks-node-group-role"
  assume_role_policy = templatefile("${path.module}/assume-role-policy.json.tmpl",{principal_arn = var.principal_arn
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#-------------------------------#
# Security Group for Node Group
#-------------------------------#
resource "aws_security_group" "node_group_sg" {
  name        = "eks-node-group-sg"
  description = "SG for EKS node group"
  vpc_id      = module.vpc.vpc_id

  # Allow all outbound
  egress {
  # checkov:skip=CKV_AWS_382 "Required for public node group to access internet"
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Control Plane -> Nodes (kubelet)
  ingress {
    description     = "Allow EKS Control Plane to communicate with nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  # Allow node-to-node communication
  ingress {
    description = "Allow node-to-node communication TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow node-to-node communication UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  tags = {
    Name = "${var.project_name}-eks-node-group-sg"
  }
}


#--------------------#
# EKS cluster
#--------------------#
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.13"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access       = true
  enable_irsa                          = true
  create_kms_key                       = true
  kms_key_enable_default_policy        = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # access to all
  kms_key_administrators               = ["arn:aws:iam::701173654142:user/admin"]

  cluster_addons = {
    coredns = {
      addon_version     = "v1.28.2-eksbuild.20"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = "v1.28.2-eksbuild.20"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = "v1.28.2-eksbuild.20"
      resolve_conflicts = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      addon_version     = "v1.28.2-eksbuild.20"
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
            type = "cluster" #full access to cluster
          }
        }
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
# --------------------
# EKS Managed Node Group
# --------------------

module "eks_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 20.13"

  cluster_name    = module.eks.cluster_name
  cluster_version = "1.29"

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

  name         = "system-node-group"
  subnet_ids   = module.vpc.public_subnets
  iam_role_arn = aws_iam_role.node_group.arn

  min_size     = 1
  max_size     = 3
  desired_size = 1

  instance_types = ["t3.small"]

  cluster_service_cidr = var.cluster_service_cidr
  vpc_security_group_ids = [aws_security_group.node_group_sg.id]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# EKS Cluster info
data "aws_eks_cluster_auth" "this" {
    name = module.eks.cluster_name
   }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# ---------------------------
# Karpenter IAM Role & Instance Profile
# ---------------------------

data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_node_role" {
  name               = "${var.project_name}-karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_cni_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_registry_policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "karpenter_node_instance_profile" {
  name = "${var.project_name}-karpenter-node-instance-profile"
  role = aws_iam_role.karpenter_node_role.name
}

# ---------------------------
# Karpenter Controller IAM Role for IRSA
# ---------------------------

data "aws_iam_policy_document" "karpenter_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")
      }:sub"
      values = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.project_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role.json
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  name   = "${var.project_name}-karpenter-controller-policy"
  policy = file("${path.module}/karpenter-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

#------------------------#
# Helm release Karpenter
#------------------------#
resource "helm_release" "karpenter" {
  name = "karpenter"
  chart = "oci://public.ecr.aws/karpenter/karpenter"
  namespace        = "karpenter"
  create_namespace = true
  version          = "~> 1.5.0"

set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_node_instance_profile.name
  }
}

#------------------------------------#
# Provisioner template & local_file
#------------------------------------#
data "template_file" "karpenter_provisioner" {
  template = file("${path.module}/templates/provisioner.yaml.tpl")

  vars = {
    cluster_name = module.eks.cluster_name
  }
}

resource "local_file" "karpenter_provisioner" {
  content  = data.template_file.karpenter_provisioner.rendered
  filename = "${path.module}/../karpenter/provisioner.yaml"
}

resource "aws_kms_key" "ecr" {
  description = "KMS key for ECR repository encryption"
  deletion_window_in_days = 7
}

#-------#
# ECR 
#-------#
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  encryption_type = "KMS"
  kms_key         = aws_kms_key.ecr.arn
  environment     = var.environment
}
