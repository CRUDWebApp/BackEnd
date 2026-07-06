#!/bin/bash

OUTPUT=$(cdk deploy --require-approval never --outputs-file outputs.json)

SECRET_NAME=$(jq -r '.WebAppStack.KeyPairSecretName' outputs.json)

aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text > ec2-key.pem

chmod 400 ec2-key.pem

echo "Private key downloaded to ec2-key.pem"