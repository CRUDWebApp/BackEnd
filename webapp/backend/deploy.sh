
# ssh ec2-user@<ip> -i ../../infrastructure/ec2-key

#sudo kubectl exec -it deploy/hello-world-api -- sh

# sudo mkdir -p /etc/rancher/k3s
# sudo nano /etc/rancher/k3s/config.yaml

# tls-san:
#   - <ip>

# curl -sfL https://get.k3s.io | \
# INSTALL_K3S_EXEC="\
# --tls-san 44.211.56.78 \
# --disable traefik" \
# sh -

# or

# aws ssm send-command \
#   --instance-ids i-xxxxxxxx \
#   --document-name "AWS-RunShellScript" \
#   --parameters commands='[
#     "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"--tls-san 44.211.56.78 --disable traefik\" sh -"
#   ]'

# sudo openssl x509 \
# -in /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt \
# -text \
# -noout | grep -A1 "Subject Alternative Name"

# sudo cat /etc/rancher/k3s/k3s.yaml
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

SECRET_NAME=$(jq -r '
.RDSStack
| to_entries[]
| select(.key | test("RDSDatabaseSecretArn"))
| .value
' ../../infrastructure/outputs.json)

SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text \
  --secret-id "$SECRET_NAME")

# In PC
IMAGE="$REPO_URI/$REPO_NAME:$ImageName"
export KUBECONFIG=~/.kube/ec2.yaml

kubectl get nodes

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text)

HOST=$(echo "$SECRET_JSON" | jq -r '.host')
PORT=$(echo "$SECRET_JSON" | jq -r '.port')
DB=$(echo "$SECRET_JSON" | jq -r '.dbname')
USER=$(echo "$SECRET_JSON" | jq -r '.username')
PASS=$(echo "$SECRET_JSON" | jq -r '.password')

DATABASE_URL="postgresql://${USER}:${PASS}@${HOST}:${PORT}/${DB}"

PASSWORD=$(aws ecr get-login-password --region "$Region")

kubectl create secret docker-registry ecr-secret \
  --docker-server="$REPO_URI" \
  --docker-username=AWS \
  --docker-password="$PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic backend-secret \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl delete job prisma-migrate --ignore-not-found
kubectl wait --for=delete job/prisma-migrate --timeout=60s || true

sed "s|{{image}}|$IMAGE|g" k8s/migration.yaml | kubectl apply -f -

kubectl wait \
    --for=condition=complete \
    job/prisma-migrate \
    --timeout=300s

sed "s|{{image}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -

kubectl apply -f k8s/service.yaml

kubectl rollout status deployment/hello-world-api

