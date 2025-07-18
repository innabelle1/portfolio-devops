node {
  jobDsl targets: 'seed/create-jenkins-jobs.groovy',
         removedJobAction: 'IGNORE',
         removedViewAction: 'IGNORE',
         lookupStrategy: 'SEED_JOB'
}
