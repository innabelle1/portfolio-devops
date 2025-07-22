from pathlib import Path

# Services list
services = [
    "config-server",
    "discovery-server",
    "customers-service",
    "visits-service",
    "vets-service",
    "genai-service",
    "api-gateway",
    "admin-server"
]

jenkinsfile_template = """\
pipeline {{
  agent any

  parameters {{
    string(name: 'SERVICE_NAME', defaultValue: '{name}', description: 'Microservice name')
    string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Tag of the local image')
  }}

  environment {{
    AWS_REGION   = 'us-east-1'
    ECR_REGISTRY = '701173654142.dkr.ecr.us-east-1.amazonaws.com'
    ECR_REPO     = "${{ECR_REGISTRY}}/petclinic/${{params.SERVICE_NAME}}"
    LOCAL_IMAGE  = "innabelle1/petclinic-${{params.SERVICE_NAME}}:${{params.IMAGE_TAG}}"
  }}

  stages {{

    stage('Login to ECR') {{
      steps {{
    withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
      sh """
        aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
        aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
        aws configure set default.region us-east-1
        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 701173654142.dkr.ecr.us-east-1.amazonaws.com
      """
      }}
    }}

    stage('Tag Local Image for ECR') {{
      steps {{
        sh "docker tag $LOCAL_IMAGE $ECR_REPO:$IMAGE_TAG"
      }}
    }}

    stage('Push Image to ECR') {{
      steps {{
        sh "docker push $ECR_REPO:$IMAGE_TAG"
      }}
    }}

    stage('Verify Push') {{
      steps {{
        sh '''
          aws ecr describe-images \
            --repository-name petclinic/${{params.SERVICE_NAME}} \
            --image-ids imageTag=$IMAGE_TAG \
            --region $AWS_REGION
        '''
      }}
    }}
  }}

  post {{
    success {{
      echo "Successfully pushed ${{params.SERVICE_NAME}}:$IMAGE_TAG to $ECR_REPO"
    }}
    failure {{
      echo "Failed to push ${{params.SERVICE_NAME}}:$IMAGE_TAG"
    }}
  }}
}}
"""

# Generate Jenkinsfile for each microservice
for name in services:
    folder = Path(f"./spring-petclinic-{name}")
    if folder.exists():
        jenkinsfile = folder / "Jenkinsfile"
        jenkinsfile.write_text(jenkinsfile_template.format(name=name))
        print(f"Created: {jenkinsfile}")
    else:
        print(f"older not found: {folder}")
