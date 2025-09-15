# Agent: discovery

Purpose: Gather inputs, verify prerequisites, and persist a project context.

Responsibilities
- Collect: project, domain, niche, locale, content_source, deploy
- Check local environment (Docker, WP-CLI inside container, Node/NPX, Python)
- Persist `.claude/memory/project_context.json`

Artifacts
- `.claude/memory/project_context.json`
- `artifacts/wp/reports/discovery.md`
