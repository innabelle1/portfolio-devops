import os
import subprocess
import sys
from pathlib import Path

# ---Create venv if not exists and install pyyaml
venv_dir = Path("venv")
if not venv_dir.exists():
    subprocess.run([sys.executable, "-m", "venv", "venv"])
    print("Created virtual environment: ./venv")

pip_exec = venv_dir / "bin" / "pip"

# -----Install PyYAML inside venv
subprocess.run([str(pip_exec), "install", "pyyaml"])

import yaml

# ------Project directory
BASE_DIR = Path(__file__).resolve().parent

# folders prefix
prefix = "spring-petclinic-"

# ------Services list & ports
services = {
    "discovery-server": 8761,
    "customers-service": 8081,
    "visits-service": 8082,
    "vets-service": 8083,
    "genai-service": 8084,
    "api-gateway": 8085,
    "admin-server": 9090,
    "config-server": 8888
}


# --- Maven Build 
print("Maven: building all services...")
build_result = subprocess.run(["mvn", "clean", "install", "-DskipTests"], cwd=BASE_DIR)

if build_result.returncode != 0:
    print("Maven build failed.")
    sys.exit(1)

# ----------Generate  Dockerfile
def get_dockerfile_content(service, port):
    return f"""FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE {port}
RUN apt-get update && apt-get install -y curl
ENTRYPOINT ["java", "-jar", "app.jar"]
"""

for name, port in services.items():
    folder = BASE_DIR / f"{prefix}{name}"
    pom = folder / "pom.xml"
    target = folder / "target"
    dockerfile = folder / "Dockerfile"

    if not pom.exists():
        print(f"{name}: no pom.xml")
        continue

    if not target.exists() or not any(target.glob("*.jar")):
        print(f"{name}: no target/*.jar")
        continue

    dockerfile.write_text(get_dockerfile_content(name, port))
    print(f"Dockerfile is created in: {dockerfile}")

# --------- .env FILES 
env_openai = """\
OPENAI_API_KEY=your-openai-key-here
"""
env_bedrock = """\
AWS_ACCESS_KEY_ID=your-openai-key-here
AWS_SECRET_ACCESS_KEY=your-openai-key-here
AWS_REGION=us-east-1
BEDROCK_MODEL_ID=amazon.titan-tg1-large
"""

Path(".env.openai").write_text(env_openai)
Path(".env.bedrock").write_text(env_bedrock)
print("Files .env.openai и .env.bedrock are created")

# ----------- Makefile
makefile_content = """\

ENV_FILE ?= .env.openai
COMPOSE_FILE ?= docker-compose.yml

build:
\tdocker compose -f $(COMPOSE_FILE) build

up:
\tdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d

clean:
\t@echo "Clean Docker containers, images, and volumes..."
\t@docker compose -f $(COMPOSE_FILE)  --env-file $(ENV_FILE)  down -v --remove-orphans
\t@docker image prune -f
\t@docker volume prune -f
\t@echo "Optionally cleaning Maven target folders..."
\t@find . -type d -name 'target' -exec rm -rf {} +

down:
\tdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

switch-openai:
\t@$(MAKE) up ENV_FILE=.env.openai

switch-bedrock:
\t@$(MAKE) up ENV_FILE=.env.bedrock

"""

Path("Makefile").write_text(makefile_content)

# ------------- docker-compose.yml
compose = {
    "services": {},
}

for name, port in services.items():
    folder_name = f"{prefix}{name}"
    dockerfile_path = f"{folder_name}/Dockerfile"
    entry = {
        "build": {"context": f"./{folder_name}", "dockerfile": "Dockerfile"},
        "container_name": name,
        "ports": [f"{port}:{port}"],
    }

    if name == "discovery-server":
        entry["depends_on"] = {
            "config-server": {"condition": "service_healthy"},
    }

    #if name not in ["config-server"]:
     #   entry.setdefault("depends_on", {}).update({"discovery-server":{"condition": "service_healthy"}}
    #)
    
    elif name in ["customers-service", "vets-service", "visits-service", "api-gateway"]:
        entry["depends_on"] = {
            "config-server": {"condition": "service_healthy"},
            "discovery-server": {"condition": "service_healthy"},
    }

    if name == "config-server":
        entry["healthcheck"] = {
            "test": ["CMD", "curl", "-f", "http://localhost:8888/"],
            "interval": "5s",
            "timeout": "5s",
            "retries": 10,
    }

    if name == "discovery-server":
        entry["healthcheck"] = {
            "test": ["CMD", "curl", "-f" "http://localhost:8761/"],
            "interval": "10s",
            "timeout": "5s",
            "retries": 20,
    }

    if name == "genai-service":
        entry["environment"] = [
            "OPENAI_API_KEY=${OPENAI_API_KEY}",
            "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
            "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}",
            "AWS_REGION=${AWS_REGION}",
            "BEDROCK_MODEL_ID=${BEDROCK_MODEL_ID}",
    ]

    compose["services"][name] = entry

with open("docker-compose.yml", "w") as f:
    yaml.dump(compose, f, sort_keys=False)
# --- docker-compose.override.yml
override = {
    "services": {
        name: {
            "volumes": [f"./{prefix}{name}/target:/app"],
            "command": "java -jar app.jar"
        } for name in services
    }
}
with open("docker-compose.override.yml", "w") as f:
     yaml.dump(override, f, sort_keys=False)

print(" All files are created: Dockerfile, .env, docker-compose.yml, Makefile")
print(" source venv/bin/activate —  activate env")
print(" make up   — up services (с .env.openai)")
print(" make switch-openai or switch-bedrock - switch to environment")
print(" make clean — clean all")
print(" make down — stop services")
print(" make logs — logs")
