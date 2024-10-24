FROM rancher/cli2

ENV URL=
ENV CONTEXT=
ENV TOKEN=

VOLUME /.kube

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
