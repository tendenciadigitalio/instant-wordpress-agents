#!/usr/bin/env bash
set -euo pipefail

# Post-deploy checks over SSH: permalinks, Apache AllowOverride, .htaccess, sitemap/robots
# Requires env: SSH_HOST, DOMAIN
# Optional env: SSH_USER (default=root), SSH_KEY (default=~/.ssh/wordpress_deploy), WP_PATH (default=/var/www/html)

SSH_USER="${SSH_USER:-root}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/wordpress_deploy}"
SSH_HOST="${SSH_HOST:-}"
DOMAIN="${DOMAIN:-}"
WP_PATH="${WP_PATH:-/var/www/html}"

if [[ -z "$SSH_HOST" || -z "$DOMAIN" ]]; then
  echo "Missing SSH_HOST or DOMAIN env. Set them (e.g., source .env) and retry." >&2
  exit 1
fi

ssh_exec() {
  ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "${SSH_USER}@${SSH_HOST}" "$@"
}

REPORT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)/artifacts/wp/reports"
REPORT_FILE="$REPORT_DIR/deploy.md"
mkdir -p "$REPORT_DIR"
: > "$REPORT_FILE"
log() { echo -e "$1" | tee -a "$REPORT_FILE"; }

log "# Post-Deploy Checks for ${DOMAIN}\n"

log "## WP-CLI Permalinks\n"
ssh_exec "wp --allow-root rewrite structure" | tee -a "$REPORT_FILE" || true
ssh_exec "wp --allow-root rewrite structure '/%postname%/'" | tee -a "$REPORT_FILE"
ssh_exec "wp --allow-root rewrite flush" | tee -a "$REPORT_FILE"

log "\n## Apache and .htaccess\n"
ssh_exec "sudo cat /etc/apache2/sites-enabled/wordpress.conf | sed -n '1,120p'" | tee -a "$REPORT_FILE" || true
ssh_exec "sudo test -f ${WP_PATH}/.htaccess && echo '.htaccess exists' || echo '.htaccess missing'" | tee -a "$REPORT_FILE"
ssh_exec "sudo systemctl restart apache2 && echo 'Apache restarted'" | tee -a "$REPORT_FILE"

log "\n## HTTP Checks (sitemap/robots)\n"
(curl -IsS "https://${DOMAIN}/sitemap.xml" | head -n1) | tee -a "$REPORT_FILE" || true
(curl -IsS "https://${DOMAIN}/wp-sitemap.xml" | head -n1) | tee -a "$REPORT_FILE" || true
(curl -IsS "https://${DOMAIN}/robots.txt" | head -n1) | tee -a "$REPORT_FILE" || true

log "\nDone. See report: $REPORT_FILE\n"
