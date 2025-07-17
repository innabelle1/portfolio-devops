resource "aws_ecr_repository" "this" {
  #name = var.repository_name

  for_each = toset(var.services)

  name = "petclinic/${each.key}"


  encryption_configuration {
     encryption_type = var.encryption_type
     kms_key         = var.kms_key
}

  image_tag_mutability = "IMMUTABLE" #update image you need to create new tag

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = each.key
    #Name        = var.repository_name
    Project     = var.project_name
    Environment = var.environment
  }
}
