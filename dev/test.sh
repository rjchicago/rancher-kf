#!/bin/bash
set -euo pipefail

echo "🧪 Testing rancher-kf end-to-end..."

# Track test results
TEST_FAILED=false

# Clean up old kubeconfig files
echo "Cleaning up old kubeconfig files..."
rm -f .kube/rancher.*.yaml

# Run rancher-kf
echo "Running rancher-kf..."
docker run --rm --network host -v .kube:/.kube --env-file dev/.env rjchicago/rancher-kf

# Check if new kubeconfig files were created
echo "Checking for generated kubeconfig files..."
KUBECONFIG_FILES=$(find .kube -name "rancher.*.yaml" 2>/dev/null || true)

if [ -z "$KUBECONFIG_FILES" ]; then
    echo "❌ No kubeconfig files were generated"
    exit 1
fi

echo "✅ Found kubeconfig files:"
ls -la .kube/rancher.*.yaml

# Test kubectl connectivity with each kubeconfig
for KUBECONFIG_FILE in $KUBECONFIG_FILES; do
    CLUSTER_NAME=$(basename "$KUBECONFIG_FILE" .yaml | sed 's/rancher\.//')
    echo ""
    echo "🔍 Testing kubectl connectivity for cluster: $CLUSTER_NAME"
    
    # Test kubeconfig validity
    echo "Validating kubeconfig file..."
    if kubectl --kubeconfig="$KUBECONFIG_FILE" config view >/dev/null 2>&1; then
        echo "✅ kubeconfig file is valid for $CLUSTER_NAME"
    else
        echo "❌ kubeconfig file is invalid for $CLUSTER_NAME"
        TEST_FAILED=true
        continue
    fi
    
    # Test kubectl version
    echo "Testing kubectl client..."
    if kubectl --kubeconfig="$KUBECONFIG_FILE" version --client >/dev/null 2>&1; then
        echo "✅ kubectl client works with $CLUSTER_NAME"
    else
        echo "❌ kubectl client failed with $CLUSTER_NAME"
        kubectl --kubeconfig="$KUBECONFIG_FILE" version --client 2>&1 || true
        TEST_FAILED=true
        continue
    fi
    
    # Test server connectivity
    echo "Testing server connectivity..."
    if kubectl --kubeconfig="$KUBECONFIG_FILE" get nodes >/dev/null 2>&1; then
        echo "✅ kubectl server connectivity works with $CLUSTER_NAME"
        echo "Nodes in $CLUSTER_NAME:"
        kubectl --kubeconfig="$KUBECONFIG_FILE" get nodes -o wide
    else
        echo "❌ kubectl server connectivity failed with $CLUSTER_NAME"
        echo "Error details:"
        kubectl --kubeconfig="$KUBECONFIG_FILE" get nodes 2>&1 || true
        TEST_FAILED=true
    fi
done

echo ""
if [ "$TEST_FAILED" = "true" ]; then
    echo "❌ rancher-kf test completed with failures!"
    exit 1
else
    echo "🎉 rancher-kf test completed successfully!"
fi