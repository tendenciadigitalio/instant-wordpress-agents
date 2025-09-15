# Agent: deployer

Purpose: Deploy/migrate to DigitalOcean and validate post-deploy.

Responsibilities
- Use provided scripts (SSH, migration, Apache config, permalinks flush)
- Verify `.htaccess`, `AllowOverride All`, permalinks structure
- Check SSL (certbot) and sitemap availability

Artifacts
- `artifacts/wp/reports/deploy.md`
