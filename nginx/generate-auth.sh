#!/bin/bash
# Generates nginx/auth/loki.htpasswd from credentials in log/.env
# Run this once after cloning, and again whenever you change LOKI_USERNAME/LOKI_PASSWORD.
# Requires: apache2-utils (htpasswd) or httpd-tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../log/.env"
AUTH_DIR="$SCRIPT_DIR/auth"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: $ENV_FILE not found. Create it from log/.env.example first." >&2
    exit 1
fi

# Source the env file
set -a
source "$ENV_FILE"
set +a

if [ -z "${LOKI_USERNAME:-}" ] || [ -z "${LOKI_PASSWORD:-}" ]; then
    echo "ERROR: LOKI_USERNAME and LOKI_PASSWORD must be set in $ENV_FILE" >&2
    exit 1
fi

if ! command -v htpasswd &>/dev/null; then
    echo "ERROR: htpasswd not found. Install apache2-utils (Debian/Ubuntu) or httpd-tools (RHEL/CentOS)." >&2
    exit 1
fi

mkdir -p "$AUTH_DIR"
htpasswd -Bbn "$LOKI_USERNAME" "$LOKI_PASSWORD" > "$AUTH_DIR/loki.htpasswd"
echo "Generated $AUTH_DIR/loki.htpasswd for user '$LOKI_USERNAME'."
