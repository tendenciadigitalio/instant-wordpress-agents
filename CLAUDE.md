# CLAUDE.md

This file provides guidance for Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Instant WordPress Agents is a system of specialized Claude Code subagents to create WordPress sites with strict quality controls (Zero 404), ready for local development and deployment to DigitalOcean.

## Common Commands

### Local Development
```bash
# Start local WordPress stack with Docker
docker compose up -d

# Local environment healthcheck
chmod +x scripts/wp-healthcheck.sh && ./scripts/wp-healthcheck.sh

# Install Playwright MCP (from Claude Code)
/install-playwright-mcp
```

### WordPress Automation via Subagents
```bash
# Create complete WordPress site (in Claude Code)
/wp-one-shot project:"ProjectName" domain:"example.com" niche:"SaaS" locale:"en-US" content_source:"json" deploy:false

# Validation with quality gates (Zero 404)
/wp-validate

# Optional deploy to DigitalOcean
/wp-deploy
```

### Testing and Validation
```bash
# Post-deploy checks from local
chmod +x scripts/wp-post-deploy-checks.sh
source .env && ./scripts/wp-post-deploy-checks.sh

# Security check
chmod +x scripts/wp-security-check.sh && ./scripts/wp-security-check.sh
```

## Architecture
El sistema implementa 10 subagentes especializados coordinados por el `orchestrator`:

1. **orchestrator** - Main coordinator managing the complete flow
2. **discovery** - Input and prerequisite validation
3. **content-harvester** - Content normalization into datasets
4. **schema-designer** - YAML schema generation (CPTs, taxonomies, permalinks, menus)
5. **wp-builder** - Schema application with WP-CLI and seed content
6. **seo-optimizer** - Basic SEO application
7. **qa-validator** - Validation with Playwright MCP (Zero 404 gate)
8. **security-auditor** - Security hardening checklist
9. **performance-optimizer** - Basic performance targets
10. **deployer** - Migración a DO y checks post-deploy

Referencias: ver `docs/SUBAGENTS.md` para entradas/salidas y contrato de memoria de cada subagente.

## Key Quality Gates
- **Zero 404**: Hard gate before deploy—no link can return a 404
- **Minimum SEO**: Meta tags, sitemap, robots.txt present
- **Security checklist**: Applied before deploy

## File Structure
- `agents/` - Specialized subagent definitions
- `artifacts/wp/schema/` - YAML specs for CPTs, taxonomies, menus, permalinks
- `artifacts/wp/reports/` - Validation, security, performance, deploy reports
- `scripts/` - Healthcheck, local build, post-deploy check scripts
- `wp-content/` - WordPress content (themes/plugins)
- `docs/` - Deployment, operations, troubleshooting documentation

## WordPress Development Context
- Uses **Docker** for local development (port 8080)
- **WP-CLI** available inside the `wp-dev` container
- Standard WordPress structure with themes and plugins in `wp-content/`
- Playwright MCP validation for automated UI testing

## Environment Setup
Critical variables in `.env`:
- `DO_API_TOKEN` - DigitalOcean token for automatic deploy
- `SSH_HOST`, `SSH_USER`, `SSH_KEY` - Credentials for server connection
- `DOMAIN`, `WP_PATH` - Site configuration

## Development Workflow
1. Run `wp-healthcheck.sh` to verify prerequisites
2. Use `/wp-one-shot` to generate a complete site via subagents
3. Run `/wp-validate` to ensure Zero 404
4. Optional deploy with `/wp-deploy` or documented manual process
5. Post-deploy checks with `wp-post-deploy-checks.sh`

## Dependencies
- Docker y Docker Compose
- Node.js y NPX (para Playwright MCP)
- Python 3 (opcional; solo para helpers de despliegue, el flujo nativo no lo requiere)
- Playwright MCP via `/install-playwright-mcp`

## Important Notes
- **Zero 404 is mandatory** before any production deployment
- Subagents operate in coordination—do not run them manually outside the orchestrator
- All validation is done via Playwright MCP for consistency
- YAML schema is generated automatically and should be reviewed before applying