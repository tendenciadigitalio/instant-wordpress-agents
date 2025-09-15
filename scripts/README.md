# Scripts

Utility scripts to support the Claude Code subagents workflow.

## wp-healthcheck.sh
Runs local environment checks and writes a report to `artifacts/wp/reports/healthcheck.md`.

Usage:
```bash
chmod +x scripts/wp-healthcheck.sh
scripts/wp-healthcheck.sh
```

## wp-local-build-sample.sh
Applies basic site setup using WP-CLI inside Docker (container `wp-dev` by default): permalinks, base pages, sample post, and menus.

Usage:
```bash
chmod +x scripts/wp-local-build-sample.sh
scripts/wp-local-build-sample.sh
```

Env:
- `WP_CONTAINER` (default: `wp-dev`)

## wp-post-deploy-checks.sh
Runs remote post-deploy validations over SSH: permalinks, Apache AllowOverride, .htaccess presence, sitemap/robots readiness.

Usage:
```bash
chmod +x scripts/wp-post-deploy-checks.sh
# Set env or source .env first
source .env
scripts/wp-post-deploy-checks.sh
```

Required env:
- `SSH_HOST` (e.g., droplet IP)
- `DOMAIN` (e.g., example.com)

Optional env:
- `SSH_USER` (default: root)
- `SSH_KEY` (default: ~/.ssh/wordpress_deploy)
- `WP_PATH` (default: /var/www/html)
