#!/bin/sh

set -eu

mkdir -p /etc/x-ui /root/cert

/routes.sh &

if [ -n "${XUI_LOG_LEVEL:-}" ]; then
    export XUI_LOG_LEVEL
fi

if [ -n "${XUI_ENABLE_FAIL2BAN:-}" ]; then
    export XUI_ENABLE_FAIL2BAN
fi

set -- /app/x-ui setting
has_settings=0

if [ -n "${XUI_PORT:-}" ]; then
    set -- "$@" -port "${XUI_PORT}"
    has_settings=1
fi

if [ -n "${XUI_USERNAME:-}" ]; then
    set -- "$@" -username "${XUI_USERNAME}"
    has_settings=1
fi

if [ -n "${XUI_PASSWORD:-}" ]; then
    set -- "$@" -password "${XUI_PASSWORD}"
    has_settings=1
fi

if [ -n "${XUI_WEBBASEPATH:-}" ]; then
    set -- "$@" -webBasePath "${XUI_WEBBASEPATH}"
    has_settings=1
fi

if [ -n "${XUI_LISTEN_IP:-}" ]; then
    set -- "$@" -listenIP "${XUI_LISTEN_IP}"
    has_settings=1
fi

if [ "$has_settings" -eq 1 ]; then
    "$@"
fi

if [ -n "${XUI_CERT_FILE:-}" ] && [ -n "${XUI_CERT_KEY_FILE:-}" ]; then
    /app/x-ui cert -webCert "${XUI_CERT_FILE}" -webCertKey "${XUI_CERT_KEY_FILE}"
fi

exec /app/DockerEntrypoint.sh
