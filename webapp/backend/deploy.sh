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
export KUBECONFIG=~/.kube/ec2.yaml
kubectl get nodes

sed "s|{{image}}|$IMAGE|g" k8s/deployment.yaml | cat k8s/deployment.yaml 

