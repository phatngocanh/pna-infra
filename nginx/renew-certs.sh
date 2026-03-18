#!/bin/bash
# Manual certificate renewal script - run via cron or on-demand
# Certbot renews when certs are within 30 days of expiry (Let's Encrypt = 90 days)

set -e
cd "$(dirname "$0")"

echo "### Running certbot renew..."
docker compose run --rm --entrypoint certbot certbot renew

echo "### Reloading nginx to pick up new certificates..."
docker compose exec nginx nginx -s reload

echo "### Certificate renewal complete."
