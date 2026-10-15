
FROM alpine:3.22

LABEL org.opencontainers.image.title="DevOps Diagnostic CLI"
LABEL org.opencontainers.image.description="Bash-based Linux diagnostic tool"

RUN apk add --no-cache \
    bash \
    coreutils \
    util-linux \
    iputils \
    iproute2 \
    bind-tools \
    libc-utils

WORKDIR /opt/diagnostic

COPY app/diagnostic.sh app/health-check.sh ./

RUN chmod +x diagnostic.sh health-check.sh

ENTRYPOINT ["/opt/diagnostic/diagnostic.sh"]

CMD ["help"]

