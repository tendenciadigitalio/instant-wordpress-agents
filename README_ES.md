# Agentes WordPress Instantáneos — Subagentes Claude Code

Creación de sitios WordPress en un solo comando con estrictos controles de calidad (Zero 404), listo para desarrollo local y despliegue en DigitalOcean. Este repositorio incluye subagentes nativos de Claude Code, comandos, plantillas de esquema y scripts auxiliares.

## Estructura del Repositorio
- `.claude/agents/` — Subagentes especializados (orquestador, constructor, QA, despliegue, etc.)
- `.claude/commands/` — Comandos nativos: `/wp-one-shot`, `/wp-healthcheck`, `/wp-validate`, `/wp-deploy`, `/install-playwright-mcp`
- `.claude/memory/` — Contexto del proyecto, datasets, historial de iteraciones, salidas de Playwright
- `artifacts/wp/schema/` — Esquemas YAML para CPTs, taxonomías, menús, permalinks
- `artifacts/wp/reports/` — Informes de healthcheck, validación, seguridad, rendimiento y despliegue
- `scripts/` — Healthcheck, muestra de build local, verificaciones post-despliegue
- `wp-subagents-mvp-plan.md` — Plan MVP (diseño y criterios de aceptación)

## Prerrequisitos
- Docker y Docker Compose
- Node y NPX (para Playwright MCP)
- Python 3 (para scripts de DigitalOcean)
- Opcional: token de API de DigitalOcean (`DO_API_TOKEN`)

## Prerequisitos (Guía para Principiantes)

### ✅ Lo que necesitas instalar

**1. Docker Desktop**
```bash
# Para macOS: Descarga desde https://docker.com/products/docker-desktop
# Para Windows: Descarga desde https://docker.com/products/docker-desktop
# Para Linux (Ubuntu/Debian):
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Verifica la instalación:
docker --version
docker compose version
```

**2. Node.js (versión 18 o superior)**
```bash
# Para macOS: Descarga desde https://nodejs.org/
# Para Windows: Descarga desde https://nodejs.org/
# Para Linux (Ubuntu/Debian):
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verifica la instalación:
node --version
npm --version
```

**3. Python 3 (opcional para scripts)**
```bash
# Para macOS: preinstalado o usa brew install python3
# Para Windows: Descarga desde https://python.org/downloads/
# Para Linux: usualmente preinstalado
python3 --version
```

## Inicio Rápido

**Paso 1: Clona el repositorio**
```bash
# Usando HTTPS (recomendado para principiantes)
git clone https://github.com/tu-usuario/instant-wordpress-agents.git
cd instant-wordpress-agents

# O usando SSH si tienes las llaves configuradas
git clone git@github.com:tu-usuario/instant-wordpress-agents.git
cd instant-wordpress-agents
```

**Paso 2: Configura el archivo de entorno**
```bash
# Copia el archivo de ejemplo
cp .env.example .env

# Edita el archivo .env con tu editor favorito
# nano .env  # En Linux/macOS
# notepad .env  # En Windows
```

**Paso 3: Ejecuta validaciones de integración**
```bash
# Hace ejecutable el script
chmod +x scripts/wp-integration-guardrails.sh

# Ejecuta validaciones completas
./scripts/wp-integration-guardrails.sh
```

**Paso 4: Inicia el entorno local**
```bash
# Inicia los contenedores de WordPress
docker compose up -d

# Espera 30-60 segundos para que WordPress se inicialice
# Verifica que funcione visitando http://localhost:8080
```

**Paso 5: En Claude Code**
- Ejecuta `/install-playwright-mcp` si es necesario
- Ejecuta `/wp-one-shot project:"AcmeWP" domain:"acme.com" niche:"SaaS" locale:"es-ES" content_source:"json" deploy:false`

### 🚀 Configuración en Un Solo Comando (Alternativa)
Para una experiencia aún más simple, ejecuta nuestro setup automatizado:
```bash
# Descarga y ejecuta la configuración completa
./scripts/wp-quick-start.sh
```
Este script:
- ✅ Verifica todos los prerequisitos automáticamente
- ✅ Configura el archivo de entorno
- ✅ Ejecuta las validaciones de integración
- ✅ Inicia los contenedores de WordPress
- ✅ Realiza verificaciones finales de salud
- ✅ Te guía a la generación de tu primer sitio

## Validar
- Ejecuta `/wp-validate` para realizar chequeos automatizados con Playwright MCP.
- Zero 404 es una condición obligatoria antes del despliegue.
- El informe se guarda en `artifacts/wp/reports/validation.md`.
 - Las capturas de pantalla de QA se guardan en `.claude/memory/playwright/screenshots/`.

## Despliegue (DigitalOcean)
- Despliegue opcional en un solo comando usando `/wp-deploy` tras pasar QA.
- Ruta manual:
  ```bash
  # Accede al servidor por SSH
  ssh -i ~/.ssh/wordpress_deploy root@TU_IP

  # Verifica/ajusta permalinks y flush
  wp --allow-root rewrite structure
  wp --allow-root rewrite structure '/%postname%/'
  wp --allow-root rewrite flush

  # Verifica AllowOverride de Apache
  cat /etc/apache2/sites-enabled/wordpress.conf | sed -n '1,120p'

  # Presencia de .htaccess
  test -f /var/www/html/.htaccess && echo "exists" || echo "missing"

  # Reinicia Apache
  systemctl restart apache2
  ```
  Luego ejecuta las verificaciones post-despliegue localmente:
  ```bash
  chmod +x scripts/wp-post-deploy-checks.sh
  source .env
  ./scripts/wp-post-deploy-checks.sh
  ```
- Para pasos detallados, consulta `docs/DEPLOYMENT.md`.

## Documentación
- Guía de despliegue: `docs/DEPLOYMENT.md`
- Resolución de problemas: `docs/TROUBLESHOOTING.md`
- Runbook de operaciones: `docs/OPERATIONS.md`
- Subagentes y contratos: `docs/SUBAGENTS.md`
- Configuración de subagentes: `.claude/SETUP_NATIVE_SUBAGENTS.md`
- Plan arquitectónico: `wp-subagents-mvp-plan.md`

## Cambios
Consulta `CHANGELOG.md`.

## Licencia
MIT (o la licencia que prefieras).
