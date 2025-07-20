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

# Groovy run like seed pipeline
seed_pipeline_groovy = """\
pipeline {
  agent any

  stages {
    stage('Generate Jobs') {
      steps {
        script {
	    def dslScript = readFileFromWorkspace('seed/create-jenkins-jobs.groovy')
            jobDsl targets: def dslScript,
                   removedJobAction: 'IGNORE',
                   removedViewAction: 'IGNORE',
                   lookupStrategy: 'SEED_JOB'
        }
      }
    }
  }

  post {
    success {
      echo "Seed job completed successfully"
    }
    failure {
      echo "Seed job failed"
    }
  }
}
"""

# XML seed job from Git
seed_job_config_xml = """\
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Seed job to create Jenkins pipeline jobs from Git DSL</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.94">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@5.2.1">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/innabelle1/portfolio-devops.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/restore-devops</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
    </scm>
    <scriptPath>seed/seed-pipeline.groovy</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"""

# save files
Path("seed").mkdir(exist_ok=True)
Path("seed/create-jenkins-jobs.groovy").write_text(dsl_content)
Path("seed/seed-pipeline.groovy").write_text(seed_pipeline_groovy)
Path("seed/seed-job-config.xml").write_text(seed_job_config_xml)

# created 
print("Jenkins DSL and seed job config created:")
print("- create-jenkins-jobs.groovy: DSL script to generate jobs")
print("- seed-job-config.xml: Seed job XML for Jenkins read from Git")
print(" - seed/seed-pipeline.groovy: Pipeline scripts use like scriptPath in seed job")
print("Add file to Github & push to branche 'restore-devops'")
