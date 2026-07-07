#!/bin/bash
ImageName="hello-world-api"

Region=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRRegion"))
| .value
' ../../infrastructure/ecr-output.json)

REPO_NAME=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRtestECRRepositoryName"))
| .value
' ../../infrastructure/ecr-output.json)

REPO_URI=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("RepositoryUri"))
| .value
' ../../infrastructure/ecr-output.json)

if [ -z "$REPO_URI" ]; then
  echo "ECR repository URI not found"

else
  IMAGE="$REPO_URI/$REPO_NAME:$ImageName"
  docker image rmi "$IMAGE"
  docker system prune -f

  echo "RepositoryUri: $REPO_URI"

  docker build -t "$IMAGE" .

  docker push "$IMAGE"

  docker run -d   --restart unless-stopped   -p 3000:3000   --name hello-world-api "$IMAGE"
fi


