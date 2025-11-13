<div align="center">
  <img src="assets/logo.png" alt="Rancher-KF Logo" width="400">
</div>

# Rancher-KF

[![Docker Hub](https://img.shields.io/docker/v/rjchicago/rancher-kf?label=Docker%20Hub)](https://hub.docker.com/r/rjchicago/rancher-kf)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/rjchicago/rancher-kf/workflows/Build/badge.svg)](https://github.com/rjchicago/rancher-kf/actions)
[![Test Status](https://github.com/rjchicago/rancher-kf/workflows/Test/badge.svg)](https://github.com/rjchicago/rancher-kf/actions)

Download all kubeconfig files from Rancher with a single command: `rancher-kf`

## Overview

Managing dozens of Kubernetes clusters across different environments is a pain. Manually downloading kubeconfig files from Rancher for each cluster? Even worse. `rancher-kf` solves this by automatically discovering and downloading kubeconfig files for all your accessible clusters with a single command.

**Key Features:**
- 🚀 Bulk download kubeconfig files for all accessible clusters
- 🐳 Containerized - runs anywhere Docker does
- 🔧 Minimal config - Rancher URL and API token
- 📁 Organized output with cluster-specific files
- 🤖 Fully automated - no clicking through UIs
- ⚡ Fast - download dozens of configs in seconds

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Docker Options](#docker-options)
- [Shell Aliases](#shell-aliases)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Quick Start

Get up and running in under 5 minutes:

See the [**📖 Complete Quick Start Guide**](QUICKSTART.md) for step-by-step instructions.

## Configuration

Create a `.env` file based on `example.env`:

```bash
URL=https://rancher.example.com/
TOKEN=token-*****:***********************************************
CONTEXT=c-m-(...):p-(...)  # Optional
```

> **Note:** Do not use quotes in the `.env` file.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `URL` | ✅ | URL to your Rancher UI (e.g., `https://rancher.example.com/`) |
| `TOKEN` | ✅ | API Token created in Rancher UI |
| `CONTEXT` | ❌ | Rancher context (if not provided, automatically selects first available) |

**Context Format Examples:**
- `local:p-xxxxx`
- `c-xxxxx:p-xxxxx`
- `c-xxxxx:project-xxxxx`
- `c-m-xxxxxxxx:p-xxxxx`
- `c-m-xxxxxxxx:project-xxxxx`

### Creating Rancher API Token

1. Navigate to your Rancher UI
2. Go to **User Settings** → **API Keys**
3. Click **Add Key**
4. Select **"No Scope"** for cluster access
5. Optionally set expiration (or use `custom: 0` for no expiration)
6. Copy the generated token

📖 [Official Documentation](https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys)

## Usage

### Docker Compose

```bash
# Build the image
docker compose build

# Run the tool
docker compose run --rm rancher-kf
```

### Docker Run

**Using local `.kube` directory:**
```bash
docker run --rm -it -v $(pwd)/.kube:/.kube --env-file .env rjchicago/rancher-kf
```

**Using user profile `.kube` directory:**
```bash
docker run --rm -it -v ~/.kube:/.kube --env-file ~/.kube/rancher-kf.env rjchicago/rancher-kf
```

## Shell Aliases

Add these aliases to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# Create environment file
vi ~/.kube/rancher-kf.env

# Add rancher-kf alias
alias rancher-kf="docker run --rm -it -v ~/.kube:/.kube --env-file ~/.kube/rancher-kf.env rjchicago/rancher-kf"

# Include all kubeconfig files in KUBECONFIG environment
export KUBECONFIG=~/.kube/config$(find ${HOME}/.kube -name '*.y*ml' -printf ":%p")
```

**Usage:**
```bash
# Refresh kubeconfig files
rancher-kf

# Use kubectl with any cluster
kubectl config get-contexts
```

## Local Development

For local testing and development, see [dev/README.md](dev/README.md) for a complete K3D + Rancher setup.

```bash
# Quick local setup
./dev/setup.sh
./dev/test.sh
./dev/teardown.sh
```

## Troubleshooting

### Common Issues

**Authentication Failed:**
- Verify your `URL` and `TOKEN` are correct
- Ensure the token has proper permissions
- Check if the token has expired

**No Clusters Found:**
- Verify you have access to clusters in Rancher
- Check if the correct context is specified

**Permission Denied:**
- Ensure the `.kube` directory is writable
- Check Docker volume mount permissions

### Debug Mode

Run with verbose output:
```bash
docker run --rm -it -v ~/.kube:/.kube --env-file .env rjchicago/rancher-kf sh -x /entrypoint.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
