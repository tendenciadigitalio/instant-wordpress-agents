# Agent: content-harvester

Purpose: Normalize available content into datasets for import.

Inputs
- content_source (json|scrape)

Responsibilities
- If json: validate structure and copy into `.claude/memory/datasets/`
- If scrape: perform light extraction (provider-dependent) and normalize

Artifacts
- `.claude/memory/datasets/*.json`
- `artifacts/wp/reports/content_harvest.md`
