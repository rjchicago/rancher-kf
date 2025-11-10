FROM alpine:3.22

# Version configuration
ARG RANCHER_CLI_VERSION=2.12.3

# Metadata
LABEL maintainer="rjchicago" \
      description="Download kubeconfig files from Rancher for all accessible clusters" \
      version="1.0.0"

# Install dependencies and Rancher CLI
RUN apk add --no-cache curl ca-certificates && \
    curl -sL https://github.com/rancher/cli/releases/download/v${RANCHER_CLI_VERSION}/rancher-linux-amd64-v${RANCHER_CLI_VERSION}.tar.gz | \
    tar xz -C /tmp && \
    mv /tmp/rancher-v${RANCHER_CLI_VERSION}/rancher /usr/local/bin/ && \
    chmod +x /usr/local/bin/rancher && \
    rm -rf /tmp/rancher-v${RANCHER_CLI_VERSION}

# Environment variables
ENV URL= \
    CONTEXT= \
    TOKEN=

# Create volume for kubeconfig files
VOLUME /.kube

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD [ "sh", "-c", "command -v rancher >/dev/null 2>&1 || exit 1" ]

ENTRYPOINT [ "/entrypoint.sh" ]
