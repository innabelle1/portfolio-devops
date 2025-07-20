pipeline {
  agent any

  stages {
    stage('Generate Jobs') {
      steps {
          jobDsl targets: 'seed/jenkins-jobs-1.groovy',
                 removedJobAction: 'IGNORE',
                 removedViewAction: 'IGNORE',
                 lookupStrategy: 'SEED_JOB'
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
