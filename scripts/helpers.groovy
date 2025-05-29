def buildAndPush(serviceName) {
  def imageTagLatest = "${env.DOCKER_REPO}/${serviceName}:latest"
  def imageTagSha = "${env.DOCKER_REPO}/${serviceName}:${env.GIT_COMMIT}"

  withCredentials([
    usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')
  ]) {
    sh """
      cd ./services/${serviceName}
      echo "Building and pushing ${imageTagLatest}..."
      docker build -t ${imageTagLatest} -t ${imageTagSha} .
      echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
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
