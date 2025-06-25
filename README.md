# PNA Infrastructure

Infrastructure configuration for PNA Organization with Jenkins CI/CD and Nginx reverse proxy with SSL support.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Cloudflare account with domain `phatngocanh.xyz`
- Wildcard SSL certificate from Cloudflare

### 1. Setup SSL Certificates

1. **Get Wildcard Certificate from Cloudflare:**
   - Go to Cloudflare Dashboard → SSL/TLS → Origin Server
   - Create certificate for `*.phatngocanh.xyz` (15 years)
   - Download Origin Certificate and Private Key

2. **Place Certificates:**
   ```bash
   mkdir -p nginx/ssl
   cp /path/to/origin-certificate.pem nginx/ssl/wildcard.phatngocanh.xyz.crt
   cp /path/to/private-key.pem nginx/ssl/wildcard.phatngocanh.xyz.key
   ```

### 2. Start Services

```bash
# Start Jenkins
cd jenkins
docker-compose up -d

# Start Nginx with SSL
cd ../nginx
docker-compose up -d
```

### 3. Access Jenkins

- **URL**: https://jenkins.phatngocanh.xyz
- **Get initial password**: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

## 📁 Project Structure

```
pna-infra/
├── jenkins/
│   └── docker-compose.yaml          # Jenkins service
├── nginx/
│   ├── conf.d/
│   │   └── jenkins.phatngocanh.xyz.conf  # Jenkins proxy config
│   ├── ssl/
│   │   ├── wildcard.phatngocanh.xyz.crt  # SSL certificate
│   │   └── wildcard.phatngocanh.xyz.key  # Private key
│   ├── docker-compose.yaml          # Nginx service
│   ├── nginx.conf                   # Main nginx config
│   └── README.md                    # Detailed nginx setup
└── README.md                        # This file
```

## 🔧 Services

### Jenkins CI/CD
- **Port**: 8080 (internal)
- **Domain**: jenkins.phatngocanh.xyz
- **Features**: Docker support, persistent storage

### Nginx Reverse Proxy
- **Ports**: 80 (HTTP redirect), 443 (HTTPS)
- **SSL**: Wildcard certificate for *.phatngocanh.xyz
- **Features**: Security headers, WebSocket support, health checks

## 🔒 Security Features

- **HTTPS Only**: HTTP to HTTPS redirect
- **Security Headers**: HSTS, CSP, XSS Protection
- **SSL/TLS**: TLS 1.2+ with secure ciphers
- **Cloudflare Integration**: Full (strict) SSL mode

## 🛠️ Management Commands

### Check Service Status
```bash
# Check all services
docker ps

# Check specific service logs
docker logs jenkins
docker logs nginx-proxy
```

### Restart Services
```bash
# Restart Jenkins
docker-compose -f jenkins/docker-compose.yaml restart

# Restart Nginx
docker-compose -f nginx/docker-compose.yaml restart
```

### Update SSL Certificates
```bash
# After updating certificates
docker-compose -f nginx/docker-compose.yaml restart
```

## 🌐 Adding New Subdomains

With the wildcard certificate, you can easily add new services:

1. Create new nginx config: `nginx/conf.d/your-app.phatngocanh.xyz.conf`
2. Use existing SSL certificates
3. Configure proxy_pass to your application
4. Restart nginx

See `nginx/README.md` for detailed examples.

## 📚 Documentation

- [Nginx Setup Guide](nginx/README.md) - Detailed nginx configuration
- [Jenkins Documentation](https://www.jenkins.io/doc/) - Official Jenkins docs
- [Cloudflare SSL Guide](https://developers.cloudflare.com/ssl/) - SSL configuration

## 🔍 Troubleshooting

### Common Issues

1. **SSL Certificate Errors**
   - Verify certificates are in `nginx/ssl/`
   - Check file permissions
   - Restart nginx after certificate changes

2. **Jenkins Not Accessible**
   - Check if Jenkins is running: `docker ps`
   - Verify nginx proxy configuration
   - Check nginx logs: `docker logs nginx-proxy`

3. **DNS Issues**
   - Verify Cloudflare DNS settings
   - Check if domain points to your server IP
   - Ensure SSL/TLS mode is set to "Full (strict)"

### Useful Commands

```bash
# Test SSL certificate
openssl s_client -connect jenkins.phatngocanh.xyz:443

# Check nginx configuration
docker exec nginx-proxy nginx -t

# View real-time logs
docker logs -f nginx-proxy
docker logs -f jenkins
```