#!/bin/bash

# WARNING!!
# This script is here to store the commands that needs to be run using GCP's
# CloudShell console. Please enter each command in the console individually

# Setup project and auth
gcloud config set project fibkube
gcloud config set compute/zone asia-south1-a
gcloud container clusters get-credentials fib-cluster

# Set postgres password in the kuberantes cluster
kubectl create secret generic pgpassword --from-literal PGPASSWORD="pgpw"


# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
   > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh


# Create tiller service account to tiller for only kube-system namespace
kubectl create serviceaccount --namespace kube-system tiller

# Gran permissions to tiller
kubectl create clusterrolebinding tiller-cluster-rule \
   --clusterrole=cluster-admin \
   --serviceaccount=kube-system:tiller


# Helm configuration below does not work for Helm 3.0 or more
# Now initialize helm
helm init --service-account tiller --upgrade

# Install NGINX-Ingress
helm install stable/nginx-ingress --name my-nginx
