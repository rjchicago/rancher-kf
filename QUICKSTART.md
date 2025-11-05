# Quick Start Guide

Get up and running with `rancher-kf` in under 5 minutes.

## Prerequisites

- Docker installed and running
- Access to a Rancher instance
- Permissions to create API tokens in Rancher

## Step 1: Create Rancher API Token

1. Log into your Rancher UI
2. Navigate to **User Settings** → **API Keys**
3. Click **Add Key**
4. Select **"No Scope"** for full cluster access
5. Set expiration (optional) or use `custom: 0` for no expiration
6. Copy the generated token

📖 [Detailed Instructions](https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys)

## Step 2: Configure Environment

Create your environment file:

```bash
# Create the config file
cat > ~/.kube/rancher-kf.env << EOF
URL=https://rancher.example.com/
TOKEN=token-xxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF
```

> Replace with your actual Rancher URL and token

## Step 3: Set Up Aliases (Recommended)

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Rancher kubeconfig fetcher
alias rancher-kf="docker run --rm -it -v ~/.kube:/.kube --env-file ~/.kube/rancher-kf.env rjchicago/rancher-kf"

# Include all kubeconfig files in KUBECONFIG
export KUBECONFIG=~/.kube/config$(find ~/.kube -name '*.y*ml' -printf ":%p" 2>/dev/null)
```

Reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Step 4: Run rancher-kf

```bash
# Using the alias
rancher-kf

# Or directly with docker
docker run --rm -it -v ~/.kube:/.kube --env-file ~/.kube/rancher-kf.env rjchicago/rancher-kf
```

## Step 5: Verify Setup

Check that kubeconfig files were created:

```bash
# List downloaded configs
ls -la ~/.kube/rancher.*.yaml

# View available contexts
kubectl config get-contexts

# Switch to a cluster
kubectl config use-context <cluster-name>
```

## What Happens Next?

1. `rancher-kf` automatically connects to your Rancher instance
2. If no context is specified, it automatically selects the first available project
3. Downloads kubeconfig files for all accessible clusters
4. Files are saved as `~/.kube/rancher.<cluster-name>.yaml`
5. Use `kubectl config get-contexts` to see all available clusters

> **Note:** The tool now runs fully automated with no interactive prompts!

## Need Help?

See the main [README](README.md) for detailed documentation and troubleshooting.
