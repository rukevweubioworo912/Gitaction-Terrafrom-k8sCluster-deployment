#!/bin/bash

# Connect as root
sudo su <<'EOF'

# Update system
yum update -y

# Install Helm if not installed
if ! command -v helm &> /dev/null
then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy Prometheus using Helm
helm install prometheus prometheus-community/prometheus --namespace monitoring

# Deploy Grafana using Helm
helm install grafana grafana/grafana --namespace monitoring \
  --set adminUser=admin \
  --set adminPassword=admin \
  --set service.type=NodePort

# Get Grafana service URL
GRAFANA_NODEPORT=$(kubectl get svc grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
echo "Grafana is accessible on any node IP with port: $GRAFANA_NODEPORT"

EOF
