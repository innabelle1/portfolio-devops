pipeline {
  agent any

  stages {
    stage('Generate Jobs') {
      steps {
        script {
          jobDsl targets: 'seed/create-jenkins-jobs.groovy',
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
