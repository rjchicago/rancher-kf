#! /bin/sh
set -Eeou pipefail

: ${URL:?"URL is required"}
: ${TOKEN:?"TOKEN is required"}

if [ ! -z "$CONTEXT" ]; then
  rancher login $URL -t $TOKEN --skip-verify --context=$CONTEXT
else
  rancher login $URL -t $TOKEN --skip-verify
fi

CLUSTERS=$(rancher clusters ls --format '{{.Cluster.ID}} {{.Cluster.Name}}')

OUT_DIR=/.kube
mkdir -p $OUT_DIR

while read CLUSTER; do
  CLUSTER_ID=$(echo $CLUSTER | cut -d " " -f 1)
  CLUSTER_NAME=$(echo $CLUSTER | cut -d " " -f 2)
  # if name is not "local"
  if [ ! "$CLUSTER_NAME" == "local" ]; then
    echo "writing $CLUSTER_NAME.yaml"
    rancher clusters kf $CLUSTER_ID >> $OUT_DIR/rancher.$CLUSTER_NAME.yaml
  fi
done <<< "$CLUSTERS"
