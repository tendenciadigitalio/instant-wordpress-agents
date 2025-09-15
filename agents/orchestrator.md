# Agent: orchestrator

Purpose: Coordinate the full WordPress lifecycle and enforce quality gates.

Inputs
- project, domain, niche, locale
- content_source (json|scrape), deploy (bool)

Outputs
- Updated `.claude/memory/project_context.json`
- Artifacts under `artifacts/wp/`
- Reports under `artifacts/wp/reports/`

Flow
1) discovery → validate inputs and prerequisites
2) content-harvester → normalize content into datasets
3) schema-designer → emit YAML schema (CPTs, taxonomies, permalinks, menus)
4) wp-builder → apply schema with WP-CLI and seed content
5) seo-optimizer → apply SEO minimum
6) qa-validator → Playwright MCP (Zero 404 gate). If fail, loop back to builder/seo as needed
7) security-auditor → hardening checklist
8) performance-optimizer → basic perf targets
9) deployer (optional) → DO migration and post-deploy checks

Quality Gates
- Zero 404 before deploy
- SEO minimum present

Artifacts
- `artifacts/wp/schema/*.yaml`
- `artifacts/wp/reports/{validation,security,perf,deploy}.md`
