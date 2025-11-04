FROM rancher/cli2

# Metadata
LABEL maintainer="rjchicago" \
      description="Download kubeconfig files from Rancher for all accessible clusters" \
      version="1.0.0"

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
