#!/bin/bash
set -e

echo "🚨 ВНИМАНИЕ: Удаляются все не-дефолтные VPC и связанные с ними ресурсы!"

# Получаем список всех VPC, кроме default
VPC_IDS=$(aws ec2 describe-vpcs --query "Vpcs[?IsDefault==\`false\`].VpcId" --output text)

if [ -z "$VPC_IDS" ]; then
  echo "✅ Нет пользовательских VPC для удаления."
  exit 0
fi

for VPC_ID in $VPC_IDS; do
  echo "🔎 Удаление ресурсов VPC: $VPC_ID"

  ## Internet Gateways
  IGW_IDS=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC_ID --query "InternetGateways[].InternetGatewayId" --output text)
  for IGW in $IGW_IDS; do
    echo "🌐 Удаление Internet Gateway: $IGW"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW
  done

  ## Subnets
  SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query "Subnets[].SubnetId" --output text)
  for SUBNET in $SUBNETS; do
    echo "📦 Удаление Subnet: $SUBNET"
    aws ec2 delete-subnet --subnet-id $SUBNET
  done

  ## Route Tables (кроме main)
  RT_IDS=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --query "RouteTables[?Associations[?Main!=\`true\`]].RouteTableId" --output text)
  for RT in $RT_IDS; do
    echo "🧭 Удаление Route Table: $RT"
    aws ec2 delete-route-table --route-table-id $RT
  done

  ## Security Groups (кроме default)
  SG_IDS=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
  for SG in $SG_IDS; do
    echo "🛡️ Удаление Security Group: $SG"
    aws ec2 delete-security-group --group-id $SG
  done

  ## Network ACLs (кроме default)
  ACL_IDS=$(aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC_ID --query "NetworkAcls[?IsDefault==\`false\`].NetworkAclId" --output text)
  for ACL in $ACL_IDS; do
    echo "📛 Удаление Network ACL: $ACL"
    aws ec2 delete-network-acl --network-acl-id $ACL
  done

  ## Delete VPC
  echo "❌ Удаление VPC: $VPC_ID"
  aws ec2 delete-vpc --vpc-id $VPC_ID
  echo "✅ VPC $VPC_ID удалена!"
done
