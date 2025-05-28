def buildAndPush(serviceName) {
  def imageTag = "${env.DOCKER_REPO}/${serviceName}:latest"
  withCredentials([
    usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')
  ]) {
    sh """
      echo "Building and pushing ${imageTag}..."
      docker build -t ${imageTag} services/${serviceName}
      echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
      docker push ${imageTag}
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
