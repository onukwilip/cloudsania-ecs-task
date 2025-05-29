def helpers = load 'scripts/helpers.groovy'

pipeline {
  label 'ubuntu-docker-agent'

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
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install || true
          aws --version

          sudo apt-get update -y
          sudo apt-get install -y gnupg software-properties-common curl unzip
          curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
          echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
          sudo apt-get update && sudo apt-get install terraform -y
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
