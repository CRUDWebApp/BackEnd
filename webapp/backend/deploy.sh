#curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--disable traefik' sh -
# ssh ec2-user@44.211.56.78 -i ../../infrastructure/ec2-key

# In PC
# export KUBECONFIG=~/.kube/ec2.yaml
# kubectl get nodes