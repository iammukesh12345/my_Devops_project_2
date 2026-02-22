#!/bin/bash

# Install Helm on EC2
#
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# We will use ready-made Mongo and Redis charts.
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install MongoDB Using Helm

helm install mongo bitnami/mongodb \
  --set auth.rootPassword=root123 \
  --set auth.username=user \
  --set auth.password=apppass \
  --set auth.database=wanderlust

# verify
kubectl get pods
kubectl get svc

#Install Redis Using Helm
helm install redis bitnami/redis \
  --set auth.enabled=false

#Update Backend Connection Strings
mongodb://appuser:apppass@mongo-mongodb:27017/wanderlust



#Create Your Own Helm Chart for Backend 

#backend/ 
#Chart.yaml
#values.yaml
#templates/
helm create backend
helm install backend ./backend

#Create Your Own Helm Chart for frontend

#frontend/
#Chart.yaml
#values.yaml
#templates/
helm create frontend
helm install frontend ./frontend
