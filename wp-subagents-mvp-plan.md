# WordPress Claude Code Subagents — MVP Plan

## 1) Goals
- One-command WordPress site build with strict quality gates (Zero 404) and deploy-ready output.
- Reuse existing infra in `wordpress-repo.txt` (Docker, WP-CLI, DO deploy) via orchestrated subagents.
- Add Playwright MCP-based validation and a minimal persistent memory layout.
- Ship a customer-ready package (install, use, troubleshoot) for Gumroad.

## 2) Scope
- In: local build (Docker), schema + content ingestion, SEO basics, QA automation, optional deploy to DigitalOcean.
- Out (MVP): complex scraping at scale, multi-language sites (beyond locale presets), custom payment flows.

## 3) Architecture
- Orchestrator pattern with specialized subagents:
  - discovery → content-harvester → schema-designer → wp-builder → seo-optimizer → qa-validator → security-auditor → performance-optimizer → deployer
- Artifact-first: write specs/reports into `artifacts/wp/*` and persisted memory under `.claude/memory/*`.
- Quality gates after key phases (schema, build, QA).

## 4) Directory Layout
- `.claude/agents/`: subagent specs
- `.claude/commands/`: native slash commands
- `.claude/memory/`: project context, datasets, history, QA outputs
- `artifacts/wp/schema/`: CPT/taxonomy/permalink specs
- `artifacts/wp/reports/`: validation/security/perf/deploy reports

## 5) Subagents (Responsibilities)
- orchestrator: run full lifecycle, enforce gates, persist context, re-run on failures
- discovery: collect inputs (project, domain, niche, locale, content source), verify prerequisites
- content-harvester: normalize provided JSON or light scrape to datasets
- schema-designer: define CPTs, taxonomies, permalinks, menus → YAML specs
- wp-builder: apply schema with WP-CLI, create pages, import datasets, generate menus
- seo-optimizer: titles/descriptions, OG/Twitter, robots/sitemap, internal linking
- qa-validator: Playwright MCP, Zero 404, menu + archives traversal, breakpoints; report
- security-auditor: salts, plugins, config checks; hardening checklist
- performance-optimizer: cache/media/minify suggestions; simple vitals targets
- deployer: run DO deploy/migration scripts, post-deploy checks (permalinks/SSL)

## 6) Commands
- `/wp-one-shot` (entrypoint) → end-to-end build with optional deploy
- `/wp-healthcheck` → verify local prerequisites and MCP availability
- `/wp-validate` → run QA only (Playwright + link traversal)
- `/wp-deploy` → deploy to DO and run post-deploy checklist
- `/install-playwright-mcp` → guided setup

## 7) MCP Integration
- Playwright MCP as mandatory validation gate before deployment.
- Optional fetch/scraping providers for light content harvesting.

## 8) Memory & Artifacts
- `.claude/memory/project_context.json` (inputs, assumptions, choices)
- `.claude/memory/datasets/*` (normalized input content)
- `.claude/memory/iteration_history/*` (snapshots per run)
- `artifacts/wp/schema/*.yaml`, `artifacts/wp/reports/*.md`

## 9) Quality Gates & KPIs
- Zero 404 (hard gate before deploy)
- SEO minimum (title/desc + OG/Twitter + sitemap + robots + internal links + legal pages)
- Core Web Vitals (LCP < 2.8s, CLS < 0.1 on home + a template)
- WP hygiene (permalinks, menus, CPT archives/singles reachable)

## 10) Phased Delivery
- Sprint 0: scaffold agents/commands/memory; healthcheck + Playwright MCP setup docs
- Sprint 1: `/wp-one-shot` executes discovery → schema → build → SEO → QA → snapshot
- Sprint 2: `/wp-deploy` wired to DO scripts; post-deploy checks + SSL guidance

## 11) Acceptance Criteria (MVP)
- Running `/wp-one-shot` locally produces a site with:
  - Functional pages/menus/CPTs per spec
  - Zero 404 report
  - SEO minimum achieved
- `/wp-deploy` migrates to a DO droplet and passes post-deploy checklist

## 12) Prerequisites
- Docker + Docker Compose, Node + NPX (Playwright MCP), Python 3 (DO scripts)
- Optional: DO API token, scraping provider key(s)

## 13) Usage
- Healthcheck: `/wp-healthcheck`
- One-shot local: `/wp-one-shot project:"AcmeWP" domain:"acme.com" niche:"SaaS" locale:"en-US" content_source:"json" deploy:false`
- Validate only: `/wp-validate`
- Deploy: `/wp-deploy`

## 14) Packaging (Gumroad)
- Include quick-start, troubleshooting, and minimal templates
- Ensure idempotent runs and clear rollback steps

## 15) Risks & Mitigations
- Playwright MCP availability → document on-demand install fallback
- Permalinks and .htaccess on DO → add explicit post-deploy checks (and auto-fix)

## 16) Next Steps (Execution)
- Create scaffolding under `.claude/*` and `artifacts/wp/*`
- Implement command specs and agent stubs
- Connect QA to Playwright MCP and verify Zero 404 locally
