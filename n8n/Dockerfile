# Stage 1: Get su-exec binary from Alpine (n8n image is distroless, no apk)
FROM alpine:3.22 AS builder
RUN apk add --no-cache su-exec

# Stage 2: Custom n8n image with permission fix
FROM n8nio/n8n

USER root

COPY --from=builder /sbin/su-exec /sbin/su-exec
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
