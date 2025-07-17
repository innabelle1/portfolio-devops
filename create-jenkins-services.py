from pathlib import Path

services = {
    "spring-petclinic-config-server": 8888,
    "spring-petclinic-discovery-server": 8761,
    "spring-petclinic-customers-service": 8081,
    "spring-petclinic-visits-service": 8082,
    "spring-petclinic-vets-service": 8083,
    "spring-petclinic-genai-service": 8084,
    "spring-petclinic-api-gateway": 8085,
    "spring-petclinic-admin-server": 9090
}

jenkinsfile_template = """\
pipeline {{
    agent any

    environment {{
        AWS_REGION = 'us-east-1'
        ECR_REPO = '$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com'
        IMAGE_NAME = '{image}'
        PORT = '{port}'
    }}

    stages {{
        stage('Checkout') {{
            steps {{
                checkout scm
            }}
        }}

        stage('Build') {{
            steps {{
                sh 'mvn clean package -DskipTests'
            }}
        }}

        stage('Docker Build & Push') {{
            steps {{
                script {{
                    sh '''
                    eval $(aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO)
                    docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO/$IMAGE_NAME:$BUILD_NUMBER
                    docker push $ECR_REPO/$IMAGE_NAME:$BUILD_NUMBER
                    '''
                }}
            }}
        }}

        }}
    }}
}}
"""

# Generate Jenkinsfile in every services
for name, port in services.items():
    folder = Path(name)
    if folder.exists():
        path = folder / "Jenkinsfile"
        content = jenkinsfile_template.format(
            image=name.replace("spring-petclinic-", ""),
            release=name.replace("spring-petclinic-", ""),
            port=port
        )
        path.write_text(content)
        print(f"Created Jenkinsfile in: {path}")
    else:
        print(f" Folder not found: {name}")
