#!/bin/bash
set -e

echo "=== Updating system ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== Installing dependencies ==="
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

echo "=== Installing Docker ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Configuring containerd ==="
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

echo "=== Installing Kubernetes components ==="
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "=== Initializing Kubernetes cluster ==="
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "=== Configuring kubectl for current user ==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "=== Installing Calico CNI ==="
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

echo "=== Allowing scheduling on master (optional for single-node) ==="
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

echo "=== Installing Rancher ==="
kubectl create namespace cattle-system || true
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.localhost \
  --set replicas=1

echo "=== Waiting for Rancher to become ready ==="
kubectl -n cattle-system rollout status deploy/rancher

echo "=== Installing Argo CD ==="
kubectl create namespace argocd || true
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Exposing Argo CD server locally ==="
kubectl -n argocd patch svc argocd-server \
  -p '{"spec": {"type": "NodePort"}}'

echo "=== Installation complete ==="
echo "Rancher URL: https://rancher.localhost"
echo "Argo CD (NodePort): kubectl -n argocd get svc argocd-server"
echo "Initial Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo