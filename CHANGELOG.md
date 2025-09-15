# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]
- 

## [0.1.0] - 2025-08-25
### Added
- MVP scaffolding for WordPress Claude Code subagents (agents, commands, memory, schema)
- Actionable command docs: `/wp-one-shot`, `/wp-healthcheck`, `/install-playwright-mcp`
- Scripts: `wp-healthcheck.sh`, `wp-local-build-sample.sh`, `wp-post-deploy-checks.sh`
- Playwright MCP runbook in `qa-validator`
- Deployment documentation (README, DEPLOYMENT, TROUBLESHOOTING, OPERATIONS)

### Changed
- `wp-builder` agent: concrete WP-CLI command patterns (container `wp-dev`)

### Security
- Post-deploy checklist items for salts/SSL/firewall/backups
