#!/bin/bash
set -euo pipefail

OUTPUT_FILE="../../infrastructure/outputs.json"

INSTANCE_ID=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC21ID"))
| .value
' "$OUTPUT_FILE")

INSTANCE_PUBLIC_IP=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC21PublicIP"))
| .value
' "$OUTPUT_FILE")

echo "Instance ID: $INSTANCE_ID"
echo "Public IP : $INSTANCE_PUBLIC_IP"

echo "Installing K3s..."

COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands="[
\"curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $INSTANCE_PUBLIC_IP --disable traefik' sh -\"
]")

echo "Waiting for installation..."

while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID" \
        --instance-id "$INSTANCE_ID" \
        --query "Status" \
        --output text)

    echo "Status: $STATUS"

    if [[ "$STATUS" == "Success" ]]; then
        break
    elif [[ "$STATUS" == "Failed" || "$STATUS" == "Cancelled" || "$STATUS" == "TimedOut" ]]; then
        echo "K3s installation failed."
        exit 1
    fi

    sleep 5
done

echo "Waiting for K3s API..."

sleep 20

echo "Downloading kubeconfig..."

COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands='[
"sudo cat /etc/rancher/k3s/k3s.yaml"
]')

while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID" \
        --instance-id "$INSTANCE_ID" \
        --query "Status" \
        --output text)

    if [[ "$STATUS" == "Success" ]]; then
        break
    elif [[ "$STATUS" == "Failed" || "$STATUS" == "Cancelled" || "$STATUS" == "TimedOut" ]]; then
        echo "Cannot retrieve kubeconfig."
        exit 1
    fi

    sleep 2
done

mkdir -p ~/.kube

aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --query "StandardOutputContent" \
    --output text > ~/.kube/ec2.yaml

sed -i "s/127.0.0.1/$INSTANCE_PUBLIC_IP/g" ~/.kube/ec2.yaml

chmod 600 ~/.kube/ec2.yaml

echo
echo "===================================="
echo "K3s installed successfully."
echo "Kubeconfig: ~/.kube/ec2.yaml"
echo
echo "Test:"
echo "export KUBECONFIG=~/.kube/ec2.yaml"
echo "kubectl get nodes"
echo "===================================="
export KUBECONFIG=~/.kube/ec2.yaml
kubectl get nodes
echo "===================================="
