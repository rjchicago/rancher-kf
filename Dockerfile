FROM rancher/cli2

ENV URL=https://rancher.adstack.kube.cnvr.net/
ENV CONTEXT=local:p-rqvq7
ENV TOKEN=

VOLUME /.kube

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
