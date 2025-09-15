#!/usr/bin/env bash
set -euo pipefail

# Security audit script: pre-deployment vulnerability analysis
# Requires WP-CLI in Docker container (wp-dev by default)
# Outputs report to artifacts/wp/reports/security.md

WP_CONTAINER="${WP_CONTAINER:-wp-dev}"
REPORT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../artifacts/wp/reports && pwd)"
REPORT_FILE="$REPORT_DIR/security.md"
mkdir -p "$REPORT_DIR"

run_wp() {
  docker exec -i "$WP_CONTAINER" wp --allow-root "$@"
}

log() { echo -e "$1" | tee -a "$REPORT_FILE"; }
warn() { log "**WARN:** $1"; }
fail() { log "**FAIL:** $1"; }
pass() { log "**PASS:** $1"; }

: > "$REPORT_FILE"
log "# Security Audit Report\nGenerated: $(date)\n"

# 1) Core version and updates
log "## Core Version\n"
CORE_VER=$(run_wp core version)
log "- WordPress version: $CORE_VER"
if run_wp core check-update >/dev/null 2>&1; then
  warn "Updates available"
else
  pass "Up to date"
fi

# 2) Debug settings
log "\n## Debug Settings\n"
DEBUG_STATUS=$(run_wp eval "echo WP_DEBUG ? 'ON' : 'OFF';")
if [[ "$DEBUG_STATUS" == "ON" ]]; then
  warn "WP_DEBUG is enabled - disable for production"
else
  pass "WP_DEBUG disabled"
fi

# 3) Admin user check
log "\n## Admin Users\n"
ADMINS=$(run_wp user list --role=administrator --fields=user_login --format=csv | tail -n +2)
if echo "$ADMINS" | grep -q "admin"; then
  warn "Default 'admin' user exists - rename or remove"
else
  pass "No default admin user"
fi

# 4) File permissions (basic)
log "\n## File Permissions\n"
# Check uploads dir perms
UPLOADS_PERMS=$(run_wp eval "echo substr(sprintf('%o', fileperms(WP_CONTENT_DIR . '/uploads')), -4);")
if [[ "$UPLOADS_PERMS" -gt "755" ]]; then
  warn "Uploads dir perms too open: $UPLOADS_PERMS (should be 755 or less)"
else
  pass "Uploads perms OK: $UPLOADS_PERMS"
fi

# 5) Vulnerable plugins/themes (basic check)
log "\n## Plugins/Themes\n"
PLUGINS=$(run_wp plugin list --format=csv --fields=name,status,version | tail -n +2)
while IFS=, read -r NAME STATUS VERSION; do
  if [[ "$STATUS" == "inactive" ]]; then continue; fi
  # Placeholder: integrate with WPScan or similar for vuln checks
  log "- $NAME ($VERSION): $STATUS"
done <<< "$PLUGINS"

# 6) Database prefix
log "\n## Database Prefix\n"
PREFIX=$(run_wp db prefix)
if [[ "$PREFIX" == "wp_" ]]; then
  warn "Default DB prefix - consider changing"
else
  pass "Custom prefix: $PREFIX"
fi

# 7) Salts
log "\n## Security Keys\n"
SALTS_OK=true
for key in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
  if run_wp eval "echo constant('$key');" | grep -q "put your unique phrase here"; then
    SALTS_OK=false
    break
  fi
done
if [[ "$SALTS_OK" == false ]]; then
  warn "Default salts detected - regenerate"
else
  pass "Salts customized"
fi

# 8) Basic malware scan (common patterns)
log "\n## Malware Scan (basic)\n"
MALWARE_FOUND=false
for file in $(run_wp eval "echo glob(WP_CONTENT_DIR . '/*');" | tr ',' '\n'); do
  if run_wp eval "if (preg_match('/eval|base64|shell_exec|phpinfo/i', file_get_contents('$file'))) echo '$file\n';" | grep -q .; then
    MALWARE_FOUND=true
    warn "Suspicious content in: $file"
  fi
done
if [[ "$MALWARE_FOUND" == false ]]; then
  pass "No obvious malware patterns"
fi

log "\n## Summary\nReview warnings above. Address before deployment.\n"
