pipeline {
  agent any

  environment {
    DSL_SCRIPT_PATH = 'seed/create-jenkins-jobs.groovy'
  }

  stages {
    stage('Generate Jobs') {
      steps {
        script {
          node {
            jobDsl targets: "${env.DSL_SCRIPT_PATH}",
                   removedJobAction: 'IGNORE',
                   removedViewAction: 'IGNORE',
                   lookupStrategy: 'SEED_JOB'
          }
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
