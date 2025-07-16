from pathlib import Path
import yaml

# ====== Configuration
ecr_registry = "701173654142.dkr.ecr.us-east-1.amazonaws.com"
services = {
    "config-server": 8888,
    "discovery-server": 8761,
    "customers-service": 8081,
    "visits-service": 8082,
    "vets-service": 8083,
    "genai-service": 8084,
    "api-gateway": 8085,
    "admin-server": 9090
}

base_dir = Path("helm")

# === Generate Makefile 
makefile_path = base_dir / "Makefile"
makefile_content = """\
SERVICES = {services}
NAMESPACE = petclinic

deploy-all:
\t@for svc in $(SERVICES); do \\
\t\thelm upgrade --install $$svc ./$$svc --namespace $(NAMESPACE) --create-namespace; \\
\tdone

delete-all:
\t@for svc in $(SERVICES); do \\
\t\thelm uninstall $$svc --namespace $(NAMESPACE); \\
\tdone

lint-all:
\t@for svc in $(SERVICES); do \\
\t\thelm lint ./$$svc; \\
\tdone
""".format(services=" ".join(services.keys()))
makefile_path.write_text(makefile_content)

# === helm/ & charts

for name, port in services.items():
    chart_path = base_dir / name
    templates_path = chart_path / "templates"
    templates_path.mkdir(parents=True, exist_ok=True)

    # Chart.yaml
    chart_yaml = {
        "apiVersion": "v2",
        "name": name,
        "version": "0.1.0",
        "appVersion": "1.0"
    }
    with open(chart_path / "Chart.yaml", "w") as f:
        yaml.dump(chart_yaml, f)

    # values.yaml
    values_yaml = {
        "image": {
            "repository": f"{ecr_registry}/petclinic/{name}",
            "tag": "latest",
            "pullPolicy": "IfNotPresent"
        },
        "service": {
            "type": "ClusterIP",
            "port": port
        },
        "replicaCount": 1
    }
    with open(chart_path / "values.yaml", "w") as f:
        yaml.dump(values_yaml, f)

    # templates/deployment.yaml
    deployment_yaml = f"""apiVersion: apps/v1
kind: Deployment
metadata:
  name: {name}
spec:
  replicas: {{ {{ .Values.replicaCount }} }}
  selector:
    matchLabels:
      app: {name}
  template:
    metadata:
      labels:
        app: {name}
    spec:
      containers:
        - name: {name}
          image: "{{{{ .Values.image.repository }}}}:{{{{ .Values.image.tag }}}}"
          imagePullPolicy: "{{{{ .Values.image.pullPolicy }}}}"
          ports:
            - containerPort: {{{{ .Values.service.port }}}}
"""
    with open(templates_path / "deployment.yaml", "w") as f:
        f.write(deployment_yaml)

    # templates/service.yaml
    service_yaml = f"""apiVersion: v1
kind: Service
metadata:
  name: {name}
spec:
  selector:
    app: {name}
  ports:
    - port: {{{{ .Values.service.port }}}}
      targetPort: {{{{ .Values.service.port }}}}
  type: {{{{ .Values.service.type }}}}
"""
    with open(templates_path / "service.yaml", "w") as f:
        f.write(service_yaml)
