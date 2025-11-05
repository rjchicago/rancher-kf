#!/bin/bash
set -euo pipefail

# Version configuration
RANCHER_VERSION="2.12.3"
CERT_MANAGER_VERSION="v1.13.0"

echo "🚀 Setting up local Rancher + K3D for testing rancher-kf..."

# Check prerequisites
for cmd in kubectl helm jq curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ $cmd is required but not installed"
        exit 1
    fi
done

# Install k3d if not present
if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# Clean up existing cluster if it exists
if k3d cluster list | grep -q rancher-test; then
    echo "Removing existing cluster..."
    k3d cluster delete rancher-test
fi

# Create k3d cluster
echo "Creating k3d cluster 'rancher-test'..."
k3d cluster create rancher-test \
    --image rancher/k3s:v1.31.5-k3s1 \
    --servers 1 \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --wait

# Set kubeconfig to avoid conflicts
export KUBECONFIG=$(k3d kubeconfig write rancher-test)

# Install cert-manager
echo "Installing cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace \
    --set crds.enabled=true \
    --wait

# Install Rancher
echo "Installing Rancher..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
helm upgrade --install rancher rancher-latest/rancher \
    --namespace cattle-system --create-namespace \
    --set hostname=rancher.local \
    --set bootstrapPassword=admin \
    --set replicas=1 \
    --wait

# Wait for Rancher to be ready
echo "Waiting for Rancher to be ready..."
kubectl wait --for=condition=Ready pod -l app=rancher -n cattle-system --timeout=300s

# Add rancher.local to /etc/hosts
echo "Adding rancher.local to /etc/hosts..."
if ! grep -q "rancher.local" /etc/hosts; then
    echo "127.0.0.1 rancher.local" | sudo tee -a /etc/hosts
fi

# Wait for Rancher API to be available
echo "Waiting for Rancher API to be available..."
for i in {1..30}; do
    if curl -sk https://rancher.local:8443/ping >/dev/null 2>&1; then
        echo "Rancher API is responding"
        break
    fi
    echo "Attempt $i/30: Waiting for Rancher API..."
    sleep 10
done

# Additional wait for bootstrap to complete
echo "Waiting for bootstrap to complete..."
sleep 10

# Create API token programmatically
echo "Creating API token..."

# Login and get token (with retries)
for i in {1..5}; do
    TOKEN=$(curl -sk -X POST https://rancher.local:8443/v3-public/localProviders/local?action=login \
      -H 'Content-Type: application/json' \
      -d '{"username":"admin","password":"admin"}' 2>/dev/null | \
      jq -r '.token' 2>/dev/null)
    
    if [[ "$TOKEN" != "null" && "$TOKEN" != "" ]]; then
        echo "Successfully logged in"
        break
    fi
    echo "Login attempt $i/5 failed, retrying..."
    sleep 10
done

if [[ "$TOKEN" == "null" || "$TOKEN" == "" ]]; then
    echo "❌ Failed to login to Rancher after 5 attempts"
    echo "Try accessing https://rancher.local:8443 manually to complete setup"
    exit 1
fi

# Create API key
API_TOKEN=$(curl -sk -X POST https://rancher.local:8443/v3/tokens \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"type":"token","description":"rancher-kf-test"}' | \
  jq -r '.token')

# Write .env file
cat > dev/.env << EOF
URL=https://rancher.local:8443/
TOKEN=$API_TOKEN
EOF

if [[ "$API_TOKEN" != "null" && "$API_TOKEN" != "" ]]; then
    echo "✅ Setup complete!"
    echo "🌐 Rancher UI: https://rancher.local:8443"
    echo "🔑 Username: admin"
    echo "🔑 Password: admin"
    echo "📄 API token written to dev/.env"
    echo ""
    echo "Test rancher-kf:"
    echo "docker run --rm -it --network host -v .kube:/.kube --env-file dev/.env rjchicago/rancher-kf"
else
    echo "⚠️  Setup complete but API token creation failed"
    echo "🌐 Rancher UI: https://rancher.local:8443"
    echo "🔑 Username: admin"
    echo "🔑 Password: admin"
    echo "📝 Manually create API token and update dev/.env"
    echo "Test with: docker run --rm -it --network host -v .kube:/.kube --env-file dev/.env rjchicago/rancher-kf"
fi