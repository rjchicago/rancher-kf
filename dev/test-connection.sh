#!/bin/bash

echo "🔍 Testing Rancher connectivity..."

# Test direct localhost connection
echo "Testing localhost:8443..."
curl -sk https://localhost:8443/ping && echo " ✅ localhost works" || echo " ❌ localhost failed"

# Test rancher.local
echo "Testing rancher.local:8443..."
curl -sk https://rancher.local:8443/ping && echo " ✅ rancher.local works" || echo " ❌ rancher.local failed"

# Check /etc/hosts
echo "Checking /etc/hosts for rancher.local..."
grep rancher.local /etc/hosts || echo "❌ rancher.local not in /etc/hosts"

# Check k3d cluster status
echo "Checking k3d cluster..."
k3d cluster list

# Check port forwarding
echo "Checking port 8443..."
lsof -i :8443 || echo "❌ Nothing listening on port 8443"

echo ""
echo "🐳 Testing from container (with host network)..."
docker run --rm --network host alpine:3.19 sh -c "
  apk add --no-cache curl >/dev/null 2>&1
  echo 'Testing localhost:8443 from container with host network...'
  curl -sk https://localhost:8443/ping 2>/dev/null && echo ' ✅ localhost works with host network' || echo ' ❌ localhost failed with host network'
  echo 'Testing rancher.local:8443 from container with host network...'
  curl -sk https://rancher.local:8443/ping 2>/dev/null && echo ' ✅ rancher.local works with host network' || echo ' ❌ rancher.local failed with host network'
"