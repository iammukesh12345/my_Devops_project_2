#!/bin/bash

# ==========================================================
# Kubernetes Single Node Setup Script (kubeadm)
# Author: Mukesh DevOps Setup
# Purpose:
#   - Safe to re-run
#   - Automatically resets old cluster
#   - Fixes TLS certificate issues
#   - Installs containerd
#   - Installs kubeadm, kubelet, kubectl
#   - Initializes cluster
#   - Installs Calico CNI
#   - Makes node schedulable (single node)
# ==========================================================

set -e  # Exit immediately if any command fails

echo "========== PRE-CLEANUP: Resetting Old Kubernetes Setup (If Exists) =========="

# Check if Kubernetes was previously initialized
if [ -f /etc/kubernetes/admin.conf ]; then
    echo "Existing cluster detected. Resetting kubeadm..."
    sudo kubeadm reset -f
fi

# Remove leftover Kubernetes directories
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd
sudo rm -rf $HOME/.kube

# Unset KUBECONFIG variable (prevents TLS issues)
unset KUBECONFIG

# Restart container runtime to clear old state
sudo systemctl restart containerd || true

echo "Old Kubernetes setup cleaned successfully."


echo "========== STEP 1: Disable Swap =========="

# Kubernetes requires swap to be disabled
sudo swapoff -a

# Comment swap entry permanently in fstab
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Swap disabled."
free -h


echo "========== STEP 2: Enable Required Kernel Modules =========="

# Load required modules immediately
sudo modprobe overlay
sudo modprobe br_netfilter

# Persist modules across reboot
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo "Kernel modules enabled."


echo "========== STEP 3: Configure Sysctl Parameters =========="

# Required networking settings for Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl changes
sudo sysctl --system

echo "Sysctl networking parameters configured."


echo "========== STEP 4: Install Container Runtime (containerd) =========="

sudo apt update -y
sudo apt install -y containerd

# Create default containerd config
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enable Systemd Cgroup driver (critical for kubeadm stability)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "containerd installed and configured properly."


echo "========== STEP 5: Install Kubernetes Components =========="

sudo apt install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings

# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y

# Install kubeadm, kubelet, kubectl
sudo apt install -y kubelet kubeadm kubectl

# Prevent accidental upgrades
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes components installed."


echo "========== STEP 6: Initialize Kubernetes Cluster =========="

# Initialize cluster with pod network CIDR (required for Calico)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16


echo "========== STEP 7: Configure kubectl (Fix TLS & Auth Issues) =========="

# Create kube directory
mkdir -p $HOME/.kube

# Copy fresh admin.conf (contains new certificates)
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config

# Fix ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "kubectl configured with fresh certificates."


echo "========== STEP 8: Install Calico CNI Plugin =========="

# Install networking plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "Waiting for node to become Ready..."
sleep 40

kubectl get nodes


echo "========== STEP 9: Remove Control Plane Taint (Single Node Setup) =========="

# Allow control-plane node to run workloads
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

echo "Node is now schedulable."


echo "========== Kubernetes Single Node Setup Completed Successfully =========="
echo ""
echo "Verify cluster using:"
echo "kubectl get nodes"
echo "kubectl get pods -A"



mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

