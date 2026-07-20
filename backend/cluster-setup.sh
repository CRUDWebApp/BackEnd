#!/bin/bash
# set -euo pipefail

OUTPUT_FILE="./outputs.json"

REGION=$(jq -r '.EKSStack | to_entries[] | select(.key | test("Region")) | .value' "$OUTPUT_FILE")
if [ -z "$REGION" ] || [ "$REGION" == "null" ]; then
    REGION="us-east-1"
fi

CLUSTER_NAME=$(jq -r '.EKSStack | to_entries[] | select(.key | test("ClusterName")) | .value' "$OUTPUT_FILE")
SECRET_NAME=$(jq -r '.RDSStack | to_entries[] | select(.key | test("RDSDatabaseSecretArn")) | .value' "$OUTPUT_FILE")

echo "=================================================================="
echo "CONNECT TO EKS CLUSTER"
echo "=================================================================="
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
echo "updating ~/.kube/config successfully !"

echo "================================================================a=="
echo "GET DATABASE INFORMATION & CREATE K8S SECRET"
echo "=================================================================="
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text)

HOST=$(echo "$SECRET_JSON" | jq -r '.host')
PORT=$(echo "$SECRET_JSON" | jq -r '.port')
DB=$(echo "$SECRET_JSON" | jq -r '.dbname')
USER=$(echo "$SECRET_JSON" | jq -r '.username')
PASS=$(echo "$SECRET_JSON" | jq -r '.password')

DATABASE_URL="postgresql://${USER}:${PASS}@${HOST}:${PORT}/${DB}?schema=public"

# Tạo secret cho K8s
kubectl create secret generic backend-secret \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ SET UP CLUSTER COMPLETELY!"