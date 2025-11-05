#!/bin/sh
set -euo pipefail

# Validate required environment variables
: ${URL:?"ERROR: URL environment variable is required"}
: ${TOKEN:?"ERROR: TOKEN environment variable is required"}

echo "Connecting to Rancher at: $URL"

# Login to Rancher with proper error handling
if [ -n "${CONTEXT:-}" ]; then
  echo "Using context: $CONTEXT"
  if ! rancher login "$URL" -t "$TOKEN" --skip-verify --context="$CONTEXT"; then
    echo "ERROR: Failed to login with context $CONTEXT" >&2
    exit 1
  fi
else
  echo "No context specified, auto-selecting first available context"
  # Get first available context automatically
  if ! echo "1" | rancher login "$URL" -t "$TOKEN" --skip-verify; then
    echo "ERROR: Failed to login to Rancher" >&2
    exit 1
  fi
fi

echo "Fetching cluster list..."
if ! CLUSTERS=$(rancher clusters ls --format '{{.Cluster.ID}} {{.Cluster.Name}}'); then
  echo "ERROR: Failed to fetch clusters" >&2
  exit 1
fi



if [ -z "$CLUSTERS" ]; then
  echo "WARNING: No clusters found or accessible"
  exit 0
fi

OUT_DIR=/.kube
mkdir -p "$OUT_DIR"

echo "$CLUSTERS" | while IFS= read -r CLUSTER; do
  [ -z "$CLUSTER" ] && continue
  
  CLUSTER_ID=$(echo "$CLUSTER" | cut -d " " -f 1)
  CLUSTER_NAME=$(echo "$CLUSTER" | cut -d " " -f 2-)
  
  if [ -z "$CLUSTER_ID" ]; then
    echo "Skipping cluster with empty ID: $CLUSTER_NAME"
  else
    echo "Writing kubeconfig for: $CLUSTER_NAME"
    if ! rancher clusters kf "$CLUSTER_ID" > "$OUT_DIR/rancher.$CLUSTER_NAME.yaml"; then
      echo "WARNING: Failed to get kubeconfig for cluster $CLUSTER_NAME" >&2
    fi
  fi
done

echo "Completed successfully"
