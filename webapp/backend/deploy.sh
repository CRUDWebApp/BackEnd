#curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--disable traefik' sh -
# ssh ec2-user@44.211.56.78 -i ../../infrastructure/ec2-key
#!/bin/bash
ImageName="hello-world-api"

Region=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRRegion"))
| .value
' ../../infrastructure/outputs.json)

REPO_NAME=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("ECRRepositoryName"))
| .value
' ../../infrastructure/outputs.json)

REPO_URI=$(jq -r '
.ECRStack
| to_entries[]
| select(.key | test("RepositoryUri"))
| .value
' ../../infrastructure/outputs.json)

# In PC
IMAGE="$REPO_URI/$REPO_NAME:$ImageName"
export KUBECONFIG=~/.kube/ec2.yaml
kubectl get nodes

PASSWORD=$(aws ecr get-login-password --region $Region)
kubectl create secret docker-registry ecr-secret \
    --docker-server=$REPO_URI \
    --docker-username=AWS \
    --docker-password="$PASSWORD"

sed "s|{{image}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -

kubectl rollout restart deployment hello-world-api