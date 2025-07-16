#cluster_name  = "spring-petclinic-eks"
node_role_arn = "arn:aws:iam::701173654142:role/eks-node-role"
principal_arn = "arn:aws:iam::701173654142:user/admin"
iam_user_name = "admin"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
key_name             = "my-ssh-key"
