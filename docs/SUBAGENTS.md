# Subagentes Nativos — WordPress One‑Shot

Esta guía documenta entradas, salidas, artefactos y contrato de memoria de los 10 subagentes nativos usados por el flujo de 1 comando.

## Visión General
- Orquestación: `orchestrator` encadena 9 etapas y aplica quality gates.
- Gate obligatorio: Zero 404 (via `qa-validator`) antes de cualquier despliegue.
- Estado persistente: `.claude/memory/project_context.json` y snapshots por corrida en `.claude/memory/iteration_history/`.
- Artefactos: `artifacts/wp/schema/*.yaml`, `artifacts/wp/reports/*.md`, Playwright en `.claude/memory/playwright/`.

## 1) orchestrator
- Inputs: `project, domain, niche, locale?, content_source= json|scrape, deploy?`
- Acciones: coordina etapas, actualiza memoria, maneja reintentos, aplica gates.
- Memory keys:
  - `inputs`: parámetros de la invocación
  - `environment`: presencia de docker/wpcli/node/python, `baseUrl`
  - `status`: fase, timestamps, `last_error`
  - `qa`: `zero404_passed` (bool), `report_path`
- Outputs: reportes bajo `artifacts/wp/reports/`, context actualizado.

## 2) discovery
- Propósito: validar parámetros y prerrequisitos, inicializar contexto.
- Checks: Docker, WP-CLI, Node/NPX, Python (opcional), DO token (si deploy).
- Artefactos: `artifacts/wp/reports/healthcheck.md`.
- Memory keys: `environment.{docker,node,python,wpcli}`, `environment.baseUrl`.

## 3) content-harvester
- Propósito: normalizar contenido desde `json` o `scrape`.
- Artefactos: `.claude/memory/datasets/*.json` (+ assets si aplica).
- Memory keys: `datasets.index` (rutas de datasets), `content.summary`.

## 4) schema-designer
- Propósito: emitir especificaciones YAML para WordPress.
- Artefactos: `artifacts/wp/schema/{cpts,taxonomies,menus,permalinks}.yaml`.
- Memory keys: `schema.paths` (mapa a cada yaml), `schema.niche`.

## 5) wp-builder
- Propósito: aplicar schema con WP-CLI, seed de contenido y navegación.
- Acciones: crear CPTs/taxonomías, configurar permalinks, menús, páginas base.
- Artefactos: `artifacts/wp/reports/build.md` (opcional), logs.
- Memory keys: `build.wpcli_used`, `build.menu_items`, `build.flush_rewrite=true`.

## 6) seo-optimizer
- Propósito: SEO mínimo (titles, descriptions, sitemap, robots, OG/Twitter).
- Artefactos: `artifacts/wp/reports/seo.md` (resumen de cambios).
- Memory keys: `seo.sitemap`, `seo.robots`, `seo.meta_applied=true`.

## 7) qa-validator (GATE)
- Propósito: Zero 404 + sanidad UI con Playwright MCP.
- Descubrimiento de rutas: `routes.json` → `sitemap.xml`/`wp-sitemap.xml` → menús.
- Viewports: mobile y desktop (override en `routes.json.viewports`).
- Artefactos: `artifacts/wp/reports/validation.md`, `.claude/memory/playwright/screenshots/`.
- Memory keys: `qa.zero404_passed`, `qa.failures[]`, `qa.screenshots[]`.

## 8) security-auditor
- Propósito: hardening básico (salts, permisos, desactivar editor, etc.).
- Artefactos: `artifacts/wp/reports/security.md`.
- Memory keys: `security.applied=true`, `security.findings[]`.

## 9) performance-optimizer
- Propósito: caché, optimización de assets/imágenes, DB optimize, CWV básicos.
- Artefactos: `artifacts/wp/reports/performance.md`.
- Memory keys: `perf.cache_enabled`, `perf.image_optimizations[]`.

## 10) deployer (opcional)
- Propósito: migrar a servidor (p.ej., DigitalOcean), SSL y checks post-deploy.
- Precondición: `qa.zero404_passed == true`.
- Artefactos: `artifacts/wp/reports/deploy.md`.
- Memory keys: `deploy.host`, `deploy.certbot=true`, `deploy.completed_at`.

## Flujo y Reintentos
- Estado feliz: discovery → harvester → schema → builder → seo → qa (gate) → security → perf → deploy (si aplica).
- Reintentos: ante fallo QA, reingresar desde `wp-builder` o `seo-optimizer` según la causa.
- Límite: hasta 2 reintentos automáticos si el fallo es recuperable.

## Interfaces de Comando
- Crear sitio: `/wp-one-shot project:"Acme" domain:"acme.com" niche:"blog" [deploy:true]`
- Validación QA: `/wp-validate [baseUrl:"http://localhost:8080"]`
- Despliegue: `/wp-deploy domain:"acme.com" ssl:true`

## Ubicaciones Clave
- Memoria: `.claude/memory/`
- Esquemas: `artifacts/wp/schema/`
- Reportes: `artifacts/wp/reports/`
- Playwright: `.claude/memory/playwright/`
