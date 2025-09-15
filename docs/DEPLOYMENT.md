# Deployment Guide (DigitalOcean or similar VPS)

This guide covers a pragmatic path to deploy a WordPress site created by the Claude Code subagents. It assumes you have a provisioned server (Ubuntu) with sudo access.

## 1) Prerequisites
- A VPS with public IP and SSH access (e.g., DigitalOcean Droplet)
- SSH key configured locally (e.g., `~/.ssh/wordpress_deploy`)
- WordPress files + database prepared (via your migration method)
- Optional: Domain pointing to server IP

## 2) Environment Setup
Create and fill `.env` based on `.env.example`:
```
cp .env.example .env
```
Variables used by scripts:
- `SSH_HOST`, `SSH_USER`, `SSH_KEY`, `DOMAIN`, `WP_PATH`

## 3) Preflight
Run the local healthcheck and ensure your Docker/dev environment is sane:
```
chmod +x scripts/wp-healthcheck.sh
./scripts/wp-healthcheck.sh
```

If you intend to use QA gates:
- Run `/install-playwright-mcp` and `/wp-validate` inside Claude Code.
- Ensure Zero 404 before deploying.

## 4) Application Migration (high-level)
You can use any preferred tool (e.g., WP Migrate, Duplicator, custom scripts). After pushing files and DB:
- Ensure WordPress is reachable at the server.
- Verify file permissions and ownership as needed (typically `www-data`).

## 5) Server-Side WP-CLI and Web Server Checks
SSH to the server and apply baseline settings:
```bash
# SSH to droplet
ssh -i ~/.ssh/wordpress_deploy root@YOUR_IP

# Verify/set permalinks and flush
wp --allow-root rewrite structure
wp --allow-root rewrite structure '/%postname%/'
wp --allow-root rewrite flush

# Verify Apache configuration (AllowOverride All expected)
cat /etc/apache2/sites-enabled/wordpress.conf | sed -n '1,120p'

# Check .htaccess presence
test -f /var/www/html/.htaccess && echo "exists" || echo "missing"

# Restart Apache
systemctl restart apache2
```

If Nginx is used, ensure rewrites are configured and `.htaccess` is not required.

## 6) Post-Deploy Checks (local script)
From your local machine:
```bash
chmod +x scripts/wp-post-deploy-checks.sh
source .env
./scripts/wp-post-deploy-checks.sh
```
This performs:
- Permalink structure and flush via remote WP-CLI
- Apache config + `.htaccess` checks
- HTTP checks: `https://DOMAIN/sitemap.xml`, `https://DOMAIN/wp-sitemap.xml`, `https://DOMAIN/robots.txt`

## 7) Production Hardening
- Set strong DB credentials and update them in `wp-config.php`
- Set `WP_DEBUG` to `false`
- Rotate salts (e.g., via `https://api.wordpress.org/secret-key/1.1/salt/`)
- Install SSL (e.g., `certbot --apache`)
- Configure firewall (e.g., `ufw allow OpenSSH`, `ufw allow "Apache Full"`, `ufw enable`)
- Set up automated backups for DB and uploads

## 8) Verification
- Home, About, Blog, Contact, privacy/legal pages load
- No 404s across main navigation
- Sitemap accessible (`/sitemap.xml` or `/wp-sitemap.xml`)
- `robots.txt` is correct (not disallowing production)
- Mixed content free (HTTPS everywhere)

## 9) Rollback Strategy
- Keep snapshot/backups (DB + uploads) before each deploy
- Restore by re-importing DB and syncing uploads if needed
- Keep a maintenance page/CDN cache invalidation plan

## 10) Appendix
- Post-deploy script: `scripts/wp-post-deploy-checks.sh`
- Healthcheck: `scripts/wp-healthcheck.sh`
- QA runbook: `.claude/agents/qa-validator.md`
