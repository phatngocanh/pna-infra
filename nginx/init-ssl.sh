#!/bin/bash

# Configuration
EMAIL="admin@phatngocanh.xyz"

# phatngocanh.xyz certificate
PNA_DOMAINS=(
    "donhang.phatngocanh.xyz"
    "bichngoc-be.phatngocanh.xyz"
    "bichngoc.phatngocanh.xyz"
    "demo-backend.phatngocanh.xyz"
    "demo.phatngocanh.xyz"
    "donhang-be.phatngocanh.xyz"
    "jenkins.phatngocanh.xyz"
    "quanly-be.phatngocanh.xyz"
    "quanly.phatngocanh.xyz"
)
PNA_CERT_NAME="donhang.phatngocanh.xyz"

# ezfi.click certificate
EZFI_DOMAINS=(
    "ezfi.click"
    "www.ezfi.click"
    "be.ezfi.click"
)
EZFI_CERT_NAME="ezfi.click"

# Ensure we are in the nginx directory
cd "$(dirname "$0")"

create_dummy_if_needed() {
    local CERT_NAME="$1"
    local CERT_DIR="./certbot/conf/live/$CERT_NAME"
    if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
        echo "### Creating dummy certificate for $CERT_NAME..."
        mkdir -p "$CERT_DIR"
        openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
            -keyout "$CERT_DIR/privkey.pem" \
            -out "$CERT_DIR/fullchain.pem" \
            -subj "/CN=localhost"
    fi
}

# Create dummy certs for both domains so nginx can start
create_dummy_if_needed "$PNA_CERT_NAME"
create_dummy_if_needed "$EZFI_CERT_NAME"

# Start Nginx (needed for ACME challenge)
echo "### Starting nginx..."
docker compose up --force-recreate -d nginx

request_cert() {
    local CERT_NAME="$1"
    shift
    local DOMAINS=("$@")
    local CERT_DIR="./certbot/conf/live/$CERT_NAME"

    # Delete dummy certificates so certbot doesn't complain
    echo "### Deleting dummy certificates for $CERT_NAME..."
    rm -rf "$CERT_DIR"

    # Convert domains array to -d arguments
    local DOMAIN_ARGS=""
    for domain in "${DOMAINS[@]}"; do
        DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
    done

    echo "### Requesting certificates for $CERT_NAME..."
    docker compose run --rm --entrypoint certbot certbot certonly \
        --webroot \
        --webroot-path /var/www/certbot/ \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        --cert-name "$CERT_NAME" \
        $DOMAIN_ARGS
}

# Request phatngocanh.xyz certificate
request_cert "$PNA_CERT_NAME" "${PNA_DOMAINS[@]}"

# Request ezfi.click certificate
request_cert "$EZFI_CERT_NAME" "${EZFI_DOMAINS[@]}"

# Reload Nginx
echo "### Reloading nginx..."
docker compose exec nginx nginx -s reload

echo "### SSL Setup complete!"
