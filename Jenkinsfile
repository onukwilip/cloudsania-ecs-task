pipeline {
  agent{
    label 'ubuntu-docker-agent'
  }

  triggers {
    pollSCM('H/2 * * * *')
  }

  environment {
    DOCKER_REPO = 'onukwilip'
    AWS_REGION = 'us-east-1'
    CLUSTER_NAME = 'cloudsania-cluster'
  }

  parameters {
    booleanParam(name: 'REDEPLOY', defaultValue: false, description: 'Force ECS service redeploy')
  }

  stages {
    stage('Initialize Helpers') {
      steps {
        script {
          helpers = load 'scripts/helpers.groovy'
        }
      }
    }

    stage('Install AWS CLI & Terraform') {
      steps {
        sh '''
          echo "Verifying network connectivity..."
          curl -I https://google.com || echo "No internet!"

          apt-get update -y

          apt-get install -y gnupg software-properties-common curl unzip ca-certificates awscli

          aws --version

          curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

          echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
          
          apt-get update && apt-get install terraform -y
          
          terraform -version
        '''
      }
    }

    stage('Build & Push Docker Images') {
      parallel {
        stage('Frontend') {
          steps {
            script {
              helpers.buildAndPush('frontend')
            }
          }
        }
        stage('Backend A') {
          steps {
            script {
              helpers.buildAndPush('backend-a')
            }
          }
        }
        stage('Backend B') {
          steps {
            script {
              helpers.buildAndPush('backend-b')
            }
          }
        }
      }
    }

    stage('Deploy Infrastructure with Terraform') {
      steps {
        dir('terraform') {
          withCredentials([
            [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds-id'],
            string(credentialsId: 'ghcr-token', variable: 'GHCR_TOKEN')
          ]) {
            sh '''
              terraform init
              terraform apply -auto-approve \
                -var 'aws_region=${AWS_REGION}' \
                -var 'ghcr_token=${GHCR_TOKEN}'
            '''
          }
        }
      }
    }

    stage('Optional: Redeploy ECS Tasks') {
      when {
        expression { return params.REDEPLOY }
      }
      parallel {
        stage('Redeploy Frontend') {
          steps {
            script {
              helpers.redeployService('frontend', env.CLUSTER_NAME, env.AWS_REGION)
            }
          }
        }
        stage('Redeploy Backend A') {
          steps {
            script {
              helpers.redeployService('backend-a', env.CLUSTER_NAME, env.AWS_REGION)
            }
          }
        }
        stage('Redeploy Backend B') {
          steps {
            script {
              helpers.redeployService('backend-b', env.CLUSTER_NAME, env.AWS_REGION)
            }
          }
        }
      }
    }
  }
}
