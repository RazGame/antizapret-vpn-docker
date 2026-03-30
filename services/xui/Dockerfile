FROM golang:1.26-alpine AS builder
WORKDIR /src
ARG TARGETARCH

RUN apk --no-cache --update add \
  build-base \
  gcc \
  curl \
  unzip

COPY 3x-ui-main/ /src/3x-ui-main/

WORKDIR /src/3x-ui-main
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"
RUN go build -ldflags "-w -s" -o build/x-ui main.go
RUN ./DockerInit.sh "$TARGETARCH"

FROM alpine
ENV TZ=Etc/UTC
WORKDIR /app

RUN apk add --no-cache --update \
  ca-certificates \
  tzdata \
  fail2ban \
  bash \
  curl \
  openssl \
  bind-tools \
  iproute2 \
  inotify-tools

COPY --from=builder /src/3x-ui-main/build/ /app/
COPY --from=builder /src/3x-ui-main/DockerEntrypoint.sh /app/
COPY --from=builder /src/3x-ui-main/x-ui.sh /usr/bin/x-ui
COPY antizapret-vpn-docker/services/xui/files/entrypoint.sh /entrypoint.sh
COPY antizapret-vpn-docker/services/xui/routes.sh /routes.sh

RUN rm -f /etc/fail2ban/jail.d/alpine-ssh.conf \
  && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local \
  && sed -i "s/^\\[ssh\\]$/&\\nenabled = false/" /etc/fail2ban/jail.local \
  && sed -i "s/^\\[sshd\\]$/&\\nenabled = false/" /etc/fail2ban/jail.local \
  && sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" /etc/fail2ban/fail2ban.conf \
  && chmod +x \
    /app/DockerEntrypoint.sh \
    /app/x-ui \
    /usr/bin/x-ui \
    /entrypoint.sh \
    /routes.sh

EXPOSE 2053
VOLUME [ "/etc/x-ui", "/root/cert" ]
ENTRYPOINT [ "/entrypoint.sh" ]
