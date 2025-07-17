// Jenkins Job DSL для config-server
pipelineJob("petclinic-config-server") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-config-server/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для discovery-server
pipelineJob("petclinic-discovery-server") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-discovery-server/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для customers-service
pipelineJob("petclinic-customers-service") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-customers-service/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для visits-service
pipelineJob("petclinic-visits-service") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-visits-service/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для vets-service
pipelineJob("petclinic-vets-service") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-vets-service/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для genai-service
pipelineJob("petclinic-genai-service") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-genai-service/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для api-gateway
pipelineJob("petclinic-api-gateway") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-api-gateway/Jenkinsfile")
      }
    }
  }
}
// Jenkins Job DSL для admin-server
pipelineJob("petclinic-admin-server") {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url("https://github.com/innabelle1/portfolio-devops.git")
          }
          branches("*/restore-devops")
        }
        scriptPath("spring-petclinic-admin-server/Jenkinsfile")
      }
    }
  }
}