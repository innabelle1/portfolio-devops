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

  parameters {{
    string(name: 'SERVICE_NAME', defaultValue: '{name}', description: 'Microservice name')
  }}

  environment {{
    AWS_REGION   = 'us-east-1'
    ECR_REGISTRY = '701173654142.dkr.ecr.us-east-1.amazonaws.com'
    ECR_REPO     = "${{ECR_REGISTRY}}/petclinic/${{params.SERVICE_NAME}}"
    IMAGE_TAG    = "${env.GIT_COMMIT ?: env.BUILD_NUMBER}"
    LOCAL_IMAGE  = "portfolio-devops-${{params.SERVICE_NAME}}:${{IMAGE_TAG}}"
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

    stage('Verify Local Image Exists') {{
      steps {{
        script {{
          def exists = sh(script: "docker image inspect $LOCAL_IMAGE > /dev/null 2>&1", returnStatus: true) == 0
          if (!exists) {{
            error "Local image not found: $LOCAL_IMAGE"
          }} else {{
            echo "Found local image: $LOCAL_IMAGE"
          }}
        }}
      }}
    }}

    stage('Login to ECR') {{
      steps {{
          withAWS(credentials: 'aws-access', region: "${{AWS_REGION}}") {{
          sh '''
            aws ecr get-login-password --region $AWS_REGION | \
            docker login --username AWS --password-stdin $ECR_REGISTRY

            docker tag $LOCAL_IMAGE $ECR_REPO:$IMAGE_TAG
            docker push $ECR_REPO:$IMAGE_TAG
          '''
          }}
      }}
    }}

    stage('Verify Image in ECR') {{
      steps {{
        script {{
          def result = sh(
            script: "aws ecr describe-images --repository-name petclinic/${{params.SERVICE_NAME}} --image-ids imageTag=${{params.IMAGE_TAG}} --region $AWS_REGION",
            returnStatus: true
          )
          if (result != 0) {{
            error "Image not found in ECR: petclinic/${{params.SERVICE_NAME}}:${{params.IMAGE_TAG}}"
          }} else {{
            echo "Image exists in ECR"
          }}
        }}
      }}
    }}
  }}

  post {{
    success {{
      echo "Pushed ${{params.SERVICE_NAME}} successfully to ECR"
    }}
    failure {{
      echo "Failed to push ${{params.SERVICE_NAME}}"
    }}
  }}
}}
"""

# generate Jenkinsfile for every services
for name in services:
    folder = Path(f"./spring-petclinic-{name}")
    if folder.exists():
        jenkinsfile = folder / "Jenkinsfile"
        jenkinsfile.write_text(jenkinsfile_template.format(name=name))
        print(f"Created: {jenkinsfile}")
    else:
        print(f"older not found: {folder}")
