apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: "node.kubernetes.io/instance-type"
      operator: In
      values: ["t3.small"]
  limits:
    resources:
      cpu: 1000
  provider:
    subnetSelector:
      karpenter.sh/discovery: ${cluster_name}
    securityGroupSelector:
      karpenter.sh/discovery: ${cluster_name}
  ttlSecondsAfterEmpty: 30
