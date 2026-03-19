#!/bin/sh
set -e

# Fix permissions on the data directory when running with a volume mount.
# The n8n image runs as user 'node' (UID 1000), but host-mounted volumes
# may be owned by root. This runs as root before dropping to node.
if [ -d /home/node/.n8n ]; then
  chown -R node:node /home/node/.n8n
fi

exec su-exec node tini -- /docker-entrypoint.sh "$@"
