# Nginx Proxy Setup for Jenkins

This directory contains the nginx configuration to proxy requests from `jenkins.phatngocanh.xyz` to your Jenkins instance.

## Setup Instructions

1. **Start Jenkins** (if not already running):
   ```bash
   cd pna-infra/jenkins
   docker-compose up -d
   ```

2. **Start the nginx proxy**:
   ```bash
   cd pna-infra/nginx
   docker-compose up -d
   ```

3. **Verify the setup**:
   - Check if nginx is running: `docker ps`
   - Test the health endpoint: `curl http://jenkins.phatngocanh.xyz/health`
   - Access Jenkins: `http://jenkins.phatngocanh.xyz`

## Configuration Details

- **Domain**: jenkins.phatngocanh.xyz
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
- Test proxy connectivity: `curl -H "Host: jenkins.phatngocanh.xyz" http://localhost`
- Verify Jenkins is accessible: `curl http://localhost:8080` 