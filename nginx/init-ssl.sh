#!/bin/bash

# Configuration
EMAIL="admin@phatngocanh.xyz"
DOMAINS=(
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
CERT_NAME="donhang.phatngocanh.xyz"
CERT_DIR="./certbot/conf/live/$CERT_NAME"

# Ensure we are in the nginx directory
cd "$(dirname "$0")"

# Create dummy certificates if they don't exist
if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    echo "### Creating dummy certificate for $CERT_NAME..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
        -keyout "$CERT_DIR/privkey.pem" \
        -out "$CERT_DIR/fullchain.pem" \
        -subj "/CN=localhost"
fi

# Start Nginx
echo "### Starting nginx..."
docker compose up --force-recreate -d nginx

# Delete dummy certificates so certbot doesn't complain
echo "### Deleting dummy certificates..."
rm -rf "$CERT_DIR"

# Convert domains array to -d arguments
DOMAIN_ARGS=""
for domain in "${DOMAINS[@]}"; do
    DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
done

# Request real certificates
echo "### Requesting real certificates..."
# We use --force-renewal to overwrite the dummy certs
docker compose run --rm --entrypoint certbot certbot certonly \
    --webroot \
    --webroot-path /var/www/certbot/ \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    --cert-name "$CERT_NAME" \
    $DOMAIN_ARGS

# Reload Nginx
echo "### Reloading nginx..."
docker compose exec nginx nginx -s reload

echo "### SSL Setup complete!"
