# 🚀 WordPress One-Shot - Guía de Inicio Rápido

Genera sitios WordPress completos con **un solo comando** en Claude Code.

## ⚡ Inicio Rápido (5 minutos)

```bash
# 1. Instalar dependencias
pip3 install -r requirements.txt

# 2. Verificar prerequisitos
./scripts/prereq-checker.sh

# 3. Iniciar WordPress local
docker compose up -d

# 4. ¡Generar tu sitio!
./scripts/wp-one-shot-wrapper.sh "MiBlog" "miblog.com" "blog" "es-ES" "json" "false"
```

## 🎯 Ejemplos de Uso

### Blog Personal
```bash
./scripts/wp-one-shot-wrapper.sh "Mi Blog Personal" "miblog.com" "blog" "es-ES" "json" "false"
```

### Tienda E-commerce
```bash
./scripts/wp-one-shot-wrapper.sh "Mi Tienda" "mitienda.com" "ecommerce" "es-ES" "json" "false"
```

### Portfolio Profesional
```bash
./scripts/wp-one-shot-wrapper.sh "Mi Portfolio" "miportfolio.com" "portfolio" "en-US" "json" "false"
```

### Sitio Corporativo
```bash
./scripts/wp-one-shot-wrapper.sh "Mi Empresa" "miempresa.com" "business" "es-ES" "json" "true"
```

## 📋 Tipos de Sitio Disponibles

| Niche | Descripción | CPTs Incluidos | Páginas |
|-------|-------------|----------------|---------|
| `blog` | Blog personal/profesional | Posts, Categorías | Inicio, Sobre nosotros, Contacto |
| `ecommerce` | Tienda online | Productos, Categorías, Marcas | Tienda, Carrito, Checkout, Políticas |
| `portfolio` | Portfolio creativo | Proyectos, Testimonios | Portfolio, Servicios, Contacto |
| `business` | Sitio corporativo | Servicios, Equipo, Casos de estudio | Servicios, Nosotros, Contacto |

## ✅ Qué Obtienes Automáticamente

- ✅ **WordPress configurado** con permalinks y páginas básicas
- ✅ **Schema personalizado** según tu niche (CPTs, taxonomías, menús)
- ✅ **SEO básico** (títulos, descripciones, sitemap, robots.txt)
- ✅ **Validación Zero 404** con Playwright MCP
- ✅ **Reportes detallados** de validación y seguridad
- ✅ **Screenshots** de todas las páginas
- ✅ **Memoria persistente** para recuperación de errores
- ✅ **Snapshots automáticos** para rollback

## 🔍 Verificar Resultados

```bash
# Ver tu sitio
open http://localhost:8080

# Revisar reporte de validación
cat artifacts/wp/reports/validation.md

# Ver estado del proyecto
./scripts/memory-manager.sh get ".project.status"

# Ver logs detallados
tail -f wp-one-shot.log
```

## 🛠️ Solución de Problemas

### Error: "Prerequisitos no cumplidos"
```bash
./scripts/prereq-checker.sh
# Sigue las instrucciones para instalar lo que falta
```

### Error: "Docker no responde"
```bash
docker compose down
docker compose up -d
# Espera 30 segundos y vuelve a intentar
```

### Error: "Validación Zero 404 falló"
```bash
# Ver qué URLs fallaron
cat artifacts/wp/reports/validation.md

# Ejecutar validación independiente
python3 scripts/playwright-zero-404.py "http://localhost:8080"
```

### Recuperar desde Error
```bash
# Ver snapshots disponibles
ls .claude/memory/snapshots/

# Restaurar desde snapshot
./scripts/memory-manager.sh snapshot "nombre_snapshot"

# Empezar completamente de nuevo
./scripts/memory-manager.sh clean
```

## 🚀 Deploy a Producción

```bash
# Con deploy automático
./scripts/wp-one-shot-wrapper.sh "Mi Sitio" "midominio.com" "blog" "es-ES" "json" "true"
```

## 📁 Estructura de Archivos Generados

```
.claude/memory/
├── project_context.json     # Estado del proyecto
├── datasets/               # Contenido normalizado
├── snapshots/             # Puntos de recuperación
└── playwright/            # Screenshots y logs

artifacts/wp/
├── schema/                # YAML specs generados
└── reports/              # Reportes de validación

wp-one-shot.log           # Logs detallados
```

## 🎉 ¡Listo!

Tu sitio WordPress está funcionando en `http://localhost:8080` con:
- Contenido de ejemplo
- SEO configurado
- Todas las páginas validadas (Zero 404)
- Listo para personalizar

**¿Problemas?** Revisa `wp-one-shot.log` o ejecuta `./scripts/prereq-checker.sh`
