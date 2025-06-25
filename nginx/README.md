# Nginx Proxy Setup for Jenkins

This directory contains the nginx configuration to proxy requests from `jenkins.pna.xyz` to your Jenkins instance.

## Setup Instructions

1. **Create the external network** (if it doesn't exist):
   ```bash
   docker network create nginx-network
   ```

2. **Start the nginx proxy**:
   ```bash
   cd pna-infra/nginx
   docker-compose up -d
   ```

3. **Verify the setup**:
   - Check if nginx is running: `docker ps`
   - Test the health endpoint: `curl http://jenkins.pna.xyz/health`
   - Access Jenkins: `http://jenkins.pna.xyz`

## Configuration Details

- **Domain**: jenkins.pna.xyz
- **Proxy Target**: Jenkins running on port 8080
- **Ports**: 80 (HTTP), 443 (HTTPS - ready for SSL)
- **WebSocket Support**: Enabled for Jenkins real-time features

## SSL Setup (Optional)

To enable HTTPS, you can:

1. Add SSL certificates to the `ssl/` directory
2. Update the nginx configuration to include SSL settings
3. Configure Cloudflare to use Full (strict) SSL mode

## Troubleshooting

- Check nginx logs: `docker logs nginx-proxy`
- Verify network connectivity: `docker network inspect nginx-network`
- Test proxy connectivity: `curl -H "Host: jenkins.pna.xyz" http://localhost` 