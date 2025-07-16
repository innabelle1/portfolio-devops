#!/bin/bash
set -e


#------------ delete EKS clusters
echo "Delete EKS clusters."
EKS_CLUSTERS=$(aws eks list-clusters --query "clusters[]" --output text)
for CLUSTER in $EKS_CLUSTERS; do
  aws eks delete-cluster --name "$CLUSTER"
  echo "EKS cluster $CLUSTER is deleted."
done

#------ Delete ECR repository
echo "Delete ECR repository."
REPOS=$(aws ecr describe-repositories --query "repositories[].repositoryName" --output text)
for REPO in $REPOS; do
  aws ecr delete-repository --repository-name "$REPO" --force
  echo "ECR repository $REPO is deleted."
done

#--------- Delete KMS keys 
echo "Delete KMS keys and alias."
KMS_KEYS=$(aws kms list-keys --query "Keys[].KeyId" --output text)
for KEY in $KMS_KEYS; do
  ARN=$(aws kms describe-key --key-id "$KEY" --query "KeyMetadata.Arn" --output text)
  ENABLED=$(aws kms describe-key --key-id "$KEY" --query "KeyMetadata.KeyManager" --output text)
  if [[ "$ENABLED" == "CUSTOMER" ]]; then
    aws kms schedule-key-deletion --key-id "$KEY" --pending-window-in-days 7
    echo "Delete KMS keys $ARN in 7 days"
  fi
done

#------- delete CloudWatch Log Groups
echo "Delete CloudWatch Log Groups..."
LOG_GROUPS=$(aws logs describe-log-groups --query "logGroups[].logGroupName" --output text)
for LG in $LOG_GROUPS; do
  aws logs delete-log-group --log-group-name "$LG"
  echo "Log Group $LG is deleted."
done

#--------- delete all VPC 
echo "Delete VPC."
VPC_IDS=$(aws ec2 describe-vpcs --query "Vpcs[?IsDefault==\`false\`].VpcId" --output text)

for VPC_ID in $VPC_IDS; do
  echo "Delete VPC: $VPC_ID"

  # Internet Gateways
  IGW_IDS=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC_ID --query "InternetGateways[].InternetGatewayId" --output text)
  for IGW in $IGW_IDS; do
    aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID"
    aws ec2 delete-internet-gateway --internet-gateway-id "$IGW"
  done

  # Subnets
  SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query "Subnets[].SubnetId" --output text)
  for SUBNET in $SUBNETS; do
    aws ec2 delete-subnet --subnet-id "$SUBNET"
  done

  # Route Tables (не main)
  RT_IDS=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --query "RouteTables[?Associations[?Main!=\`true\`]].RouteTableId" --output text)
  for RT in $RT_IDS; do
    aws ec2 delete-route-table --route-table-id "$RT"
  done

  # Security Groups (не default)
  SG_IDS=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
  for SG in $SG_IDS; do
    aws ec2 delete-security-group --group-id "$SG"
  done

  # Network ACLs (не default)
  ACL_IDS=$(aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC_ID --query "NetworkAcls[?IsDefault==\`false\`].NetworkAclId" --output text)
  for ACL in $ACL_IDS; do
    aws ec2 delete-network-acl --network-acl-id "$ACL"
  done

  # Delete Load Balancers (ALB, NLB)
  echo "Delete Load Balancers..."
  LBS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text)
  for LB in $LBS; do
    aws elbv2 delete-load-balancer --load-balancer-arn "$LB"
    echo "Load Balancer $LB deleted"
  done

  # VPC
  aws ec2 delete-vpc --vpc-id "$VPC_ID"
  echo "VPC $VPC_ID deleted"
done

