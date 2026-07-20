#!/bin/bash
ImageName="crud-app"

Region=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRRegion"))
| .value
' ./outputs.json)

REPO_NAME=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRRepositoryName"))
| .value
' ./outputs.json)

REPO_URI=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("RepositoryUri"))
| .value
' ./outputs.json)

if [ -z "$REPO_URI" ]; then
  echo "ECR repository URI not found"

else
  aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $REPO_URI
  IMAGE="$REPO_URI/$REPO_NAME:$ImageName"
  docker image rmi "$IMAGE"
  docker system prune -f

  echo "RepositoryUri: $REPO_URI"
 
  docker build -t "$IMAGE" .

  docker push "$IMAGE"

  # docker run -d   --restart unless-stopped   -p 3000:3000   --name hello-world-api "$IMAGE"
fi


