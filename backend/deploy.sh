#!/bin/bash
# set -euo pipefail

OUTPUT_FILE="./outputs.json"
ImageName="crud-app"

echo "=================================================================="
echo "GET IMAGE NAME"
echo "=================================================================="
REPO_NAME=$(jq -r '.ECRStack | to_entries[] | select(.key | test("ECRRepositoryName")) | .value' "$OUTPUT_FILE")
REPO_URI=$(jq -r '.ECRStack | to_entries[] | select(.key | test("RepositoryUri")) | .value' "$OUTPUT_FILE")

IMAGE="$REPO_URI/$REPO_NAME:$ImageName"
echo "Image name: $IMAGE"

echo "=================================================================="
echo "DATABASE MIGRATION (PRISMA)"
echo "=================================================================="
kubectl delete job prisma-migrate --ignore-not-found
kubectl wait --for=delete job/prisma-migrate --timeout=60s || true

sed "s|{{image}}|$IMAGE|g" k8s/migration.yaml | kubectl apply -f -

echo "Waiting for migration..."
if ! kubectl wait --for=condition=complete job/prisma-migrate --timeout=300s; then
    echo "❌ Migration failed! Logs:"
    kubectl logs -l job-name=prisma-migrate --tail=100
    kubectl describe job prisma-migrate
fi
echo "Migration successfully!"

echo "=================================================================="
echo "DEPLOY APP & UPDATE LOAD BALANCER"
echo "=================================================================="
# Deploy Ứng dụng
sed "s|{{image}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -

# Deploy Service và Ingress
kubectl apply -f k8s/service.yaml

echo "Waiting for app restart..."
kubectl rollout status deployment/$ImageName

echo "=================================================================="
echo "✅ DEPLOY SUCCESSFULLY!"
echo "URL: "
echo $(kubectl get svc crud-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "=================================================================="
