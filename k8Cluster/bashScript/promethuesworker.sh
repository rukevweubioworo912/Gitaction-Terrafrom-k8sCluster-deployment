#!/bin/bash



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

# Detect if node is master/control-plane
NODE_NAME=$(hostname)
IS_MASTER=$(kubectl get nodes "$NODE_NAME" -o jsonpath='{.metadata.labels.node-role\.kubernetes\.io/control-plane}')

if [ "$IS_MASTER" != "true" ]; then
    echo "Deploying Prometheus and Grafana on WORKER node $NODE_NAME..."
    
    # Deploy Prometheus
    helm install prometheus-worker prometheus-community/prometheus --namespace monitoring \
      --set server.nodeSelector."kubernetes\.io/role"="" \
      --set alertmanager.nodeSelector."kubernetes\.io/role"=""

    # Deploy Grafana
    helm install grafana-worker grafana/grafana --namespace monitoring \
      --set adminUser=admin \
      --set adminPassword=admin \
      --set service.type=NodePort \
      --set nodeSelector."kubernetes\.io/role"=""
else
    echo "This is a master node ($NODE_NAME). Skipping deployment."
fi

EOF
