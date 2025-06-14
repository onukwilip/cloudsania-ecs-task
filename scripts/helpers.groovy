def buildAndPush(serviceName) {
  def imageTagLatest = "ghcr.io/${env.DOCKER_REPO}/${serviceName}:latest"
  def imageTagSha = "ghcr.io/${env.DOCKER_REPO}/${serviceName}:${env.GIT_COMMIT}"

  withCredentials([
    usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')
  ]) {
    sh """
      cd ./services/${serviceName}
      echo "Building and pushing ${imageTagLatest}..."
      docker build -t ${imageTagLatest} -t ${imageTagSha} .
      docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD ghcr.io
      docker push ${imageTagLatest}
      docker push ${imageTagSha}
    """
  }
}

def redeployService(serviceName, clusterName, region) {
  echo "Triggering ECS redeploy for ${serviceName}..."
  sh """
    aws ecs update-service \
      --cluster ${clusterName} \
      --service ${serviceName} \
      --force-new-deployment \
      --region ${region}
  """
}

return this
