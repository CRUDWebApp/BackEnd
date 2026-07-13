#!/bin/bash
set -euo pipefail

OUTPUT_FILE="../../infrastructure/outputs.json"

INSTANCE_ID1=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC21ID"))
| .value
' "$OUTPUT_FILE")

INSTANCE_PUBLIC_IP1=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC21PublicIP"))
| .value
' "$OUTPUT_FILE")

INSTANCE_ID2=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC22ID"))
| .value
' "$OUTPUT_FILE")

INSTANCE_PUBLIC_IP2=$(jq -r '
.EC2Stack
| to_entries[]
| select(.key | test("EC22PublicIP"))
| .value
' "$OUTPUT_FILE")

mkdir -p ~/.kube

echo
echo "=================================================================="
echo "Instance ID 1: $INSTANCE_ID1"
echo "Public IP 1: $INSTANCE_PUBLIC_IP1"


echo "Installing K3s..."

COMMAND_ID1=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID1" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands="[
\"curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $INSTANCE_PUBLIC_IP1 --disable traefik' sh -\"
]")

echo "Waiting for installation..."
while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID1" \
        --instance-id "$INSTANCE_ID1" \
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

COMMAND_ID1=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID1" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands='[
"sudo cat /etc/rancher/k3s/k3s.yaml"
]')

while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID1" \
        --instance-id "$INSTANCE_ID1" \
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

aws ssm get-command-invocation \
    --command-id "$COMMAND_ID1" \
    --instance-id "$INSTANCE_ID1" \
    --query "StandardOutputContent" \
    --output text > ~/.kube/ec2-1.yaml

sed -i "s/127.0.0.1/$INSTANCE_PUBLIC_IP1/g" ~/.kube/ec2-1.yaml
chmod 600 ~/.kube/ec2-1.yaml

echo
echo "=================================================================="
echo "Instance ID 2: $INSTANCE_ID2"
echo "Public IP 2: $INSTANCE_PUBLIC_IP2"

COMMAND_ID2=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID2" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands="[
\"curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $INSTANCE_PUBLIC_IP2 --disable traefik' sh -\"
]")
echo "Waiting for installation..."

while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID2" \
        --instance-id "$INSTANCE_ID2" \
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

COMMAND_ID2=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID2" \
    --document-name "AWS-RunShellScript" \
    --query "Command.CommandId" \
    --output text \
    --parameters commands='[
"sudo cat /etc/rancher/k3s/k3s.yaml"
]')

while true; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID2" \
        --instance-id "$INSTANCE_ID2" \
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



aws ssm get-command-invocation \
    --command-id "$COMMAND_ID2" \
    --instance-id "$INSTANCE_ID2" \
    --query "StandardOutputContent" \
    --output text > ~/.kube/ec2-2.yaml

sed -i "s/127.0.0.1/$INSTANCE_PUBLIC_IP2/g" ~/.kube/ec2-2.yaml

chmod 600 ~/.kube/ec2-2.yaml

echo
echo "===================================="
echo "K3s installed successfully."
echo "Kubeconfig: ~/.kube/ec2-1.yaml"
echo
echo "Test:"
echo "export KUBECONFIG=~/.kube/ec2-1.yaml"
echo "kubectl get nodes"
echo "===================================="
export KUBECONFIG=~/.kube/ec2-1.yaml
kubectl get nodes
echo "===================================="

echo
echo "===================================="
echo "K3s installed successfully."
echo "Kubeconfig: ~/.kube/ec2-1.yaml"
echo
echo "Test:"
echo "export KUBECONFIG=~/.kube/ec2-2.yaml"
echo "kubectl get nodes"
echo "===================================="
export KUBECONFIG=~/.kube/ec2-2.yaml
kubectl get nodes
echo "===================================="
