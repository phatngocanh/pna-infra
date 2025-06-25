# Nginx Proxy Setup for Jenkins

This directory contains the nginx configuration to proxy requests from `jenkins.phatngocanh.xyz` to your Jenkins instance with HTTPS support.

## Quick Setup

1. **Start Jenkins** (if not already running):
   ```bash
   cd pna-infra/jenkins
   docker-compose up -d
   ```

2. **Setup SSL Certificates** (see SSL Setup section below)

3. **Start the nginx proxy**:
   ```bash
   cd pna-infra/nginx
   docker-compose up -d
   ```

4. **Verify the setup**:
   - Check if nginx is running: `docker ps`
   - Test the health endpoint: `curl https://jenkins.phatngocanh.xyz/health`
   - Access Jenkins: `https://jenkins.phatngocanh.xyz`

## SSL Setup with Cloudflare

### 1. Get Wildcard Certificate from Cloudflare

1. Go to your Cloudflare dashboard
2. Navigate to **SSL/TLS** → **Origin Server**
3. Click **Create Certificate**
4. Choose **15 years** validity
5. Select **`*.phatngocanh.xyz`** as the hostname (wildcard)
6. Download both files:
   - **Origin Certificate** (certificate file)
   - **Private Key** (key file)

### 2. Place Certificates

Place the downloaded files in the `ssl/` directory:

```bash
# Create ssl directory if it doesn't exist
mkdir -p nginx/ssl

# Place your certificates (replace with actual filenames)
cp /path/to/your/origin-certificate.pem nginx/ssl/wildcard.phatngocanh.xyz.crt
cp /path/to/your/private-key.pem nginx/ssl/wildcard.phatngocanh.xyz.key
```

### 3. File Structure

Your nginx directory should look like this:
```
nginx/
├── conf.d/
│   └── jenkins.phatngocanh.xyz.conf
├── ssl/
│   ├── wildcard.phatngocanh.xyz.crt    ← Origin Certificate
│   └── wildcard.phatngocanh.xyz.key    ← Private Key
├── docker-compose.yaml
├── nginx.conf
└── README.md
```

### 4. Restart Nginx

After placing the certificates:
```bash
docker-compose -f nginx/docker-compose.yaml restart
```

## Configuration Details

- **Domain**: jenkins.phatngocanh.xyz
- **Proxy Target**: Jenkins running on port 8080
- **Ports**: 80 (HTTP redirect), 443 (HTTPS)
- **SSL**: Wildcard certificate for *.phatngocanh.xyz
- **WebSocket Support**: Enabled for Jenkins real-time features
- **Security Headers**: HSTS, CSP, XSS Protection, etc.

## Cloudflare Settings

For optimal security, configure Cloudflare with:
- **SSL/TLS Mode**: Full (strict)
- **Always Use HTTPS**: Enabled
- **Minimum TLS Version**: 1.2
- **Opportunistic Encryption**: Enabled

## Troubleshooting

### Check SSL Certificate
```bash
# Test SSL connection
openssl s_client -connect jenkins.phatngocanh.xyz:443 -servername jenkins.phatngocanh.xyz

# Check certificate validity
echo | openssl s_client -connect jenkins.phatngocanh.xyz:443 -servername jenkins.phatngocanh.xyz 2>/dev/null | openssl x509 -noout -dates
```

### Check Nginx Logs
```bash
# View nginx logs
docker logs nginx-proxy

# Check nginx configuration
docker exec nginx-proxy nginx -t
```

### Test Connectivity
```bash
# Test HTTP to HTTPS redirect
curl -I http://jenkins.phatngocanh.xyz

# Test HTTPS directly
curl -I https://jenkins.phatngocanh.xyz

# Test proxy connectivity
curl -H "Host: jenkins.phatngocanh.xyz" https://localhost
```

### Common Issues

1. **SSL Certificate Errors**: Ensure certificates are in the correct location and have proper permissions
2. **403 Forbidden**: Normal for Jenkins when not authenticated
3. **Connection Refused**: Check if Jenkins is running on port 8080
4. **DNS Issues**: Verify Cloudflare DNS settings for jenkins.phatngocanh.xyz

## Adding More Subdomains

With the wildcard certificate, you can easily add more subdomains:

1. Create new nginx config file: `nginx/conf.d/your-app.phatngocanh.xyz.conf`
2. Use the same SSL certificate paths
3. Update proxy_pass to your application
4. Restart nginx

Example for a new app:
```nginx
server {
    listen 443 ssl http2;
    server_name your-app.phatngocanh.xyz;
    
    ssl_certificate /etc/nginx/ssl/wildcard.phatngocanh.xyz.crt;
    ssl_certificate_key /etc/nginx/ssl/wildcard.phatngocanh.xyz.key;
    
    location / {
        proxy_pass http://host.docker.internal:3000;  # Your app port
        # ... other proxy settings
    }
}
``` 