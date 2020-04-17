#!/bin/bash

repository_url=735575797588.dkr.ecr.us-east-1.amazonaws.com/jenkins_ecr_repo
image_name=jenkins

eval $(aws ecr get-login --region us-east-1 --no-include-email)

# If the image doesn't exists, we build it and push it to the repository.
# I'm forcing this to rebuild each time until we get the image right... remove the x on the line below to switch back to better behavior
if [[ "$(docker images -q x${repository_url} 2> /dev/null)" == "" ]]; then
  pwd
  chmod -R 755 .
  docker build -t ${image_name} .
  docker tag ${image_name}:latest ${repository_url}:latest
  docker push ${repository_url}:latest
fi
