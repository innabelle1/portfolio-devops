from pathlib import Path

# services list
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

  environment {{
    AWS_REGION   = 'us-east-1'
    ECR_REGISTRY = '701173654142.dkr.ecr.us-east-1.amazonaws.com'
    SERVICE_NAME = '{name}'
    IMAGE_TAG    = "${{env.GIT_COMMIT ?: 'latest'}}"
    ECR_REPO     = "${{ECR_REGISTRY}}/petclinic/${{SERVICE_NAME}}"
    LOCAL_IMAGE  = "portfolio-devops-${{SERVICE_NAME}}:${{IMAGE_TAG}}"
  }}

  stages {{

    stage('Checkout') {{
      steps {{
        git branch: 'restore-devops', url: 'https://github.com/innabelle1/portfolio-devops.git'
      }}
    }}

    stage('Build Docker Image') {{
      steps {{
        sh "docker build -t $LOCAL_IMAGE -f spring-petclinic-${{SERVICE_NAME}}/Dockerfile ."
      }}
    }}

    stage('Tag Image for ECR') {{
      steps {{
        sh "docker tag $LOCAL_IMAGE $ECR_REPO:$IMAGE_TAG"
      }}
    }}

    stage('Login to ECR') {{
      steps {{
        withAWS(region: "${{AWS_REGION}}", credentials: 'aws-access') {{
          sh "aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY"
        }}
      }}
    }}

    stage('Push to ECR') {{
      steps {{
        sh "docker push $ECR_REPO:$IMAGE_TAG"
      }}
    }}

    stage('Verify Image in ECR') {{
      steps {{
        withAWS(region: "${{AWS_REGION}}", credentials: 'aws-access') {{
          sh '''
            aws ecr describe-images \
              --repository-name petclinic/${{SERVICE_NAME}} \
              --image-ids imageTag=${{IMAGE_TAG}} \
              --region $AWS_REGION
          '''
        }}
      }}
    }}
  }}

  post {{
    success {{
      echo "✅ Pushed ${{SERVICE_NAME}} successfully to ECR as $IMAGE_TAG"
    }}
    failure {{
      echo "❌ Failed to push ${{SERVICE_NAME}}"
    }}
  }}
}}"""

# generate Jenkinsfile for every services
for name in services:
    folder = Path(f"./spring-petclinic-{name}")
    if folder.exists():
        jenkinsfile = folder / "Jenkinsfile"
        jenkinsfile.write_text(jenkinsfile_template.format(name=name))
        print(f"Created: {jenkinsfile}")
    else:
        print(f"older not found: {folder}")
