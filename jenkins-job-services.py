from pathlib import Path

# list of services
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

# create Groovy DSL for every pipelineJob
dsl_content = "\n".join(f"""\
// Jenkins Job DSL для {name}
pipelineJob("petclinic-{name}") {{
  definition {{
    cpsScm {{
      scm {{
        git {{
          remote {{
            url("https://github.com/innabelle1/portfolio-devops.git")
          }}
          branches("*/restore-devops")
        }}
        scriptPath("spring-petclinic-{name}/Jenkinsfile")
      }}
    }}
  }}
}}""" for name in services)

# ML- for seed job
seed_job_config = """\
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Seed job to create Jenkins pipeline jobs from DSL</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.94">
    <script>
    node {{
       jobDsl targets: 'seed/create-jenkins-jobs.groovy',
             removedJobAction: 'IGNORE',
             removedViewAction: 'IGNORE',
             lookupStrategy: 'SEED_JOB'
    }}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"""

# save files
Path("seed").mkdir(exist_ok=True)
Path("seed/create-jenkins-jobs.groovy").write_text(dsl_content)
Path("seed/seed-job-config.xml").write_text(seed_job_config)

# created 
print("Jenkins DSL and seed job config created:")
print("- create-jenkins-jobs.groovy: DSL script to generate jobs")
print("- seed-job-config.xml: XML config for seed job")
