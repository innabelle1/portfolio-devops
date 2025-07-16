#data "aws_eks_cluster_auth" "this" {
#  name = var.cluster_name
#}

#provider "kubernetes" {
#  host                   = var.cluster_endpoint
#  cluster_ca_certificate = base64decode(var.cluster_ca)
#  token                  = data.aws_eks_cluster_auth.this.token
#}

#resource "kubernetes_config_map" "aws_auth" {
#  metadata {
#    name      = "aws-auth"
#    namespace = "kube-system"
#  }

#  data = {
#    mapRoles = yamlencode([
    #  {
   #     rolearn  = var.node_group_role_arn
  #      username = "system:node:{{EC2PrivateDNSName}}"
 #       groups   = ["system:bootstrappers", "system:nodes"]
#      }
#    ])
#  }
#}
