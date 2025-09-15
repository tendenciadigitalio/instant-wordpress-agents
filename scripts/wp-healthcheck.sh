#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
REPORT_DIR="$ROOT_DIR/artifacts/wp/reports"
REPORT_FILE="$REPORT_DIR/healthcheck.md"
mkdir -p "$REPORT_DIR"

log() { echo -e "$1" | tee -a "$REPORT_FILE"; }
cmd_ok() { command -v "$1" >/dev/null 2>&1; }

: > "$REPORT_FILE"
log "# WP Healthcheck\n"

# Docker
if cmd_ok docker; then
  log "- Docker: OK ($(docker --version))"
else
  log "- Docker: MISSING"
fi

# Docker Compose
if docker compose version >/dev/null 2>&1; then
  log "- Docker Compose: OK ($(docker compose version --short || echo present))"
else
  if command -v docker-compose >/dev/null 2>&1; then
    log "- docker-compose: OK ($(docker-compose --version))"
  else
    log "- Docker Compose: MISSING"
  fi
fi

# Node & NPX
if cmd_ok node; then log "- Node: OK ($(node -v))"; else log "- Node: MISSING"; fi
if cmd_ok npx; then log "- NPX: OK ($(npx -v))"; else log "- NPX: MISSING"; fi

# Python 3
if cmd_ok python3; then log "- Python3: OK ($(python3 --version))"; else log "- Python3: MISSING"; fi

# Playwright MCP availability (on-demand)
if npx @playwright/mcp@latest --help >/dev/null 2>&1; then
  log "- Playwright MCP: OK (on-demand)"
else
  log "- Playwright MCP: Not available (run /install-playwright-mcp)"
fi

# DigitalOcean token (from env or .env)
DO_TOKEN_STATUS="missing"
if [[ -n "${DO_API_TOKEN:-}" ]]; then
  DO_TOKEN_STATUS="present (env)"
elif [[ -f "$ROOT_DIR/.env" ]]; then
  if grep -q "^DO_API_TOKEN=" "$ROOT_DIR/.env" && [[ -n "$(grep '^DO_API_TOKEN=' "$ROOT_DIR/.env" | cut -d'=' -f2-)" ]]; then
    DO_TOKEN_STATUS="present (.env)"
  fi
fi
log "- DigitalOcean token: $DO_TOKEN_STATUS"

# WordPress container
if docker ps --format '{{.Names}}' | grep -q '^wp-dev$'; then
  log "- wp-dev container: RUNNING"
  if docker exec -i wp-dev wp --allow-root core version >/dev/null 2>&1; then
    WPV=$(docker exec -i wp-dev wp --allow-root core version)
    log "  - WP-CLI inside container: OK (WordPress $WPV)"
  else
    log "  - WP-CLI inside container: FAILED"
  fi
else
  log "- wp-dev container: NOT RUNNING"
fi

log "\nHealthcheck complete. See this report at: $REPORT_FILE\n"
