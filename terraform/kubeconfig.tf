#resource "null_resource" "kubeconfig" {
# depends_on = [module.eks]

#provisioner "local-exec" {
# command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
# }
#}
