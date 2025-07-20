pipeline {
  agent any

  stages {
    stage('Generate Jobs') {
      steps {
        script {
	    def dslScript = readFileFromWorkspace('seed/create-jenkins-jobs.groovy')
            jobDsl(
                   scriptText: def dslScript,
                   removedJobAction: 'IGNORE',
                   removedViewAction: 'IGNORE',
                   lookupStrategy: 'SEED_JOB'
            ) 
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
