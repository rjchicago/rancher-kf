# Local Development Environment

Complete local testing environment for rancher-kf using K3D + Rancher.

## Prerequisites

- Docker
- kubectl
- helm
- jq
- curl

## Quick Start

```bash
# 1. Setup local Rancher + K3D cluster
./dev/setup.sh

# 2. Run end-to-end test
./dev/test.sh

# 3. Cleanup when done
./dev/teardown.sh
```

## Available Scripts

| Script | Purpose |
|--------|----------|
| `setup.sh` | Creates K3D cluster, installs Rancher, generates API token |
| `test.sh` | End-to-end test: runs rancher-kf and validates kubectl connectivity |
| `teardown.sh` | Removes K3D cluster and cleans up |
| `test-connection.sh` | Debug connectivity issues |

## What Gets Created

- **K3D cluster**: `rancher-test` with Rancher v2.12.3
- **Rancher UI**: https://rancher.local:8443 (admin/admin)
- **API token**: Auto-generated and saved to `dev/.env`
- **Kubeconfig files**: Downloaded to `.kube/rancher.*.yaml`

## Manual Testing

```bash
# Run rancher-kf manually
docker run --rm -it --network host -v .kube:/.kube --env-file dev/.env rjchicago/rancher-kf

# Use downloaded kubeconfig
kubectl --kubeconfig .kube/rancher.local.yaml get nodes
```

## Troubleshooting

```bash
# Test connectivity
./dev/test-connection.sh

# Check Rancher logs
kubectl logs -n cattle-system -l app=rancher
```

## Architecture

- **K3s v1.31.5**: Lightweight Kubernetes
- **Rancher v2.12.3**: Management platform
- **Cert-manager**: TLS certificates
- **Host networking**: Required for container connectivity