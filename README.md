# PNA Infrastructure

This repository contains the infrastructure configuration for PNA services including nginx, MySQL, and Jenkins.

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

### Update SSL Certificates (Let's Encrypt)

Certificates auto-renew via the certbot container. To renew manually or fix expired certs:

```bash
cd nginx
./renew-certs.sh   # Manual renewal + nginx reload
# Or for initial/expired setup:
./init-ssl.sh      # Full certificate request
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

## 🗄️ Database Connection

### ⚠️ **IMPORTANT: Cloudflare Configuration Required**

Your MySQL database is accessible through the domain name `database.phatngocanh.xyz` on port `3307`, but **you MUST configure Cloudflare correctly** for it to work.

### 🔧 **Cloudflare DNS Configuration**

**CRITICAL:** You must disable Cloudflare proxy for MySQL connections to work.

1. **Go to Cloudflare Dashboard** → DNS settings for `phatngocanh.xyz`
2. **Find the `database` A record**
3. **Click the orange cloud icon** to turn it **GRAY** (DNS only, no proxy)
4. **Save the changes**

```
✅ Correct: Gray cloud (DNS only)
❌ Wrong: Orange cloud (Proxy enabled)
```

### 🌐 **Why This Matters**

- **Orange Cloud (Proxy):** Only works for HTTP/HTTPS traffic (ports 80, 443)
- **Gray Cloud (DNS only):** Works for ALL protocols including MySQL (port 3307)

Cloudflare cannot proxy MySQL connections because:
- MySQL uses its own binary protocol, not HTTP
- Cloudflare is designed for web traffic only
- MySQL connections are persistent, not request-response

### 🔗 **Connection Details**

**Host:** `database.phatngocanh.xyz`  
**Port:** `3307`  
**Protocol:** MySQL TCP

### 📝 **How to Connect**

**From your local machine:**
```bash
mysql -h database.phatngocanh.xyz -P 3307 -u root -p
```

**From applications:**
```
mysql://root:password@database.phatngocanh.xyz:3307
```

**Using MySQL Workbench:**
- Host: `database.phatngocanh.xyz`
- Port: `3307`
- Username: `root`
- Password: Your MySQL root password

### 🌍 **Web Interface**

- **Status page:** `https://database.phatngocanh.xyz`
- **Health check:** `https://database.phatngocanh.xyz/health`

### 🔒 **Security Notes**

- The connection is proxied through nginx with SSL termination
- Make sure your MySQL server is properly secured with strong passwords
- Consider using specific database users instead of root for applications
- The web interface (HTTPS) works through Cloudflare proxy, but MySQL connections require DNS-only mode

### 🚨 **Troubleshooting**

**If you get "Communications link failure":**
1. Check that Cloudflare proxy is **DISABLED** (gray cloud)
2. Wait 5-30 minutes for DNS propagation
3. Verify the domain resolves to your server IP: `103.72.98.174`

**If you get "Access denied":**
- Check MySQL user permissions
- Ensure the user can connect from the Docker network

### 📁 **Configuration Files**

- `nginx/nginx.conf` - Main nginx configuration with MySQL stream proxy
- `nginx/conf.d/database.phatngocanh.xyz.conf` - HTTP/HTTPS server configuration
- `mysql/docker-compose.yaml` - MySQL container configuration

### 🐳 **Services**

- **Nginx:** Reverse proxy and MySQL TCP proxy (ports 80, 443, 3307)
- **MySQL:** Database server (port 3306 internally, 3307 externally)
- **Jenkins:** CI/CD server (port 8080)

---

**Remember:** Always use **GRAY CLOUD** (DNS only) in Cloudflare for the database subdomain! 🎯