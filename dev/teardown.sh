#!/bin/bash
set -e

echo "🧹 Tearing down local Rancher test environment..."

# Delete k3d cluster
k3d cluster delete rancher-test

echo "✅ Cleanup complete!"