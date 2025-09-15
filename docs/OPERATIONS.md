# Operations Runbook

## Backups
- Database:
  ```bash
  # Remote DB export
  wp --allow-root db export /var/www/html/db-backup-$(date +%F).sql
  ```
- Uploads:
  - Sync `/var/www/html/wp-content/uploads` to your storage (rsync, rclone, etc.)
- Automate via cron and verify restorations periodically.

## Updates
- Plugins & themes:
  ```bash
  wp --allow-root plugin update --all
  wp --allow-root theme update --all
  ```
- Core updates should be tested in staging first, then applied to production.

## Security
- Set `WP_DEBUG=false` in production
- Rotate salts regularly
- Minimum required privileges for users and SSH
- Firewall enabled (e.g., UFW) and SSH hardened

## Monitoring
- Uptime monitoring (external)
- Logs:
  - Apache: `/var/log/apache2/error.log`, `/var/log/apache2/access.log`
  - PHP-FPM (if used): `/var/log/php*-fpm.log`
- WordPress cron:
  ```bash
  wp --allow-root cron event list
  ```

## Performance
- Enable page/object caching (plugin or server-side)
- Use a CDN for static assets
- Optimize images and consider lazy loading

## Routine Health Checks
- Local healthcheck:
  ```bash
  ./scripts/wp-healthcheck.sh
  ```
- Post-deploy verification:
  ```bash
  source .env && ./scripts/wp-post-deploy-checks.sh
  ```

## Incident Response
- Capture current state: logs, versions, recent changes
- Rollback using latest DB/upload backups
- Communicate status and ETA to stakeholders
