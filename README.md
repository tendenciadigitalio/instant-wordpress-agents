# WordPress One-Shot Generator

**Generate complete WordPress sites with a single command in Claude Code**

[![Low/No-Code](https://img.shields.io/badge/Experience-Low/No--Code-blue.svg)](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
[![Subagents](https://img.shields.io/badge/Powered%20by-Subagents-green.svg)](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

## 🎯 What It Does

This tool turns Claude Code into an **automated WordPress site generator** powered by specialized subagents:

- **One command** → Working WordPress site
- **Specialized subagents** handle all complexity
- **Low/no-code** experience for users
- **Automatic quality validation** (Zero 404, SEO, security)

## 🚀 Quick Start (1 minute)

```bash
# Just run the slash command in Claude Code
/wp-one-shot project:"My Blog" domain:"myblog.com" niche:"blog"
/wp-one-shot project:"My Store" domain:"mystore.com" niche:"ecommerce" locale:"en-US" deploy:true
```

**That’s it!** The subagents handle the rest automatically.

## 🏗️ Subagent Architecture

The system uses **Claude Code native subagents** for each stage:

### 1. **orchestrator** - Main Coordinator
- ✅ Orchestrates the full 9-stage flow
- ✅ Manages state and error recovery
- ✅ Applies quality gates (Zero 404, minimum SEO)
- ✅ Reports progress in real time

### 2. **discovery** - Prerequisite Validation
- ✅ Validates input parameters
- ✅ Checks Docker, WP-CLI, Node.js
- ✅ Initializes project context
- ✅ Creates recovery snapshots

### 3. **content-harvester** - Content Normalization
- ✅ Processes JSON sources or scraping
- ✅ Normalizes content structure
- ✅ Validates and optimizes assets
- ✅ Generates standardized datasets

### 4. **schema-designer** - Information Architecture
- ✅ Designs CPTs by niche (blog, ecommerce, portfolio, business)
- ✅ Creates taxonomies and menu structures
- ✅ Configures optimized permalinks
- ✅ Generates YAML specs for WordPress

### 5. **wp-builder** - Site Construction
- ✅ Applies schemas with WP-CLI
- ✅ Imports content into WordPress
- ✅ Sets up menus and navigation
- ✅ Builds working site

### 6. **seo-optimizer** - SEO Optimization
- ✅ Sets titles and meta descriptions
- ✅ Generates sitemap and robots.txt
- ✅ Applies Open Graph and Twitter Cards
- ✅ Implements technical SEO

### 7. **qa-validator** - Zero 404 Validation
- ✅ Uses Playwright MCP for full testing
- ✅ Validates all critical routes
- ✅ Captures error screenshots
- ✅ **GATE**: Blocks deploy if 404s detected

### 8. **security-auditor** - Security Hardening
- ✅ Regenerates security salts
- ✅ Sets file permissions
- ✅ Disables risky features
- ✅ Audits user configuration

### 9. **performance-optimizer** - Performance Tuning
- ✅ Implements advanced caching
- ✅ Optimizes images and assets
- ✅ Validates Core Web Vitals
- ✅ Sets up basic CDN

### 10. **deployer** - Production Deployment
- ✅ Migrates to DigitalOcean droplet
- ✅ Sets up automatic SSL
- ✅ Post-deploy validation
- ✅ Delivers access credentials

## 📋 Automatic Quality Gates

- ✅ **Zero 404** - Playwright MCP validation
- ✅ **Minimum SEO** - Titles, descriptions, sitemap
- ✅ **Basic Security** - Salts, permissions, hardening
- ✅ **Performance** - Core Web Vitals goals met

## 🎨 Supported Niches

| Niche       | Features                        | Included CPTs      |
|-------------|---------------------------------|--------------------|
| **blog**      | Posts, categories, tags          | Posts with taxonomies |
| **ecommerce** | Products, categories, brands     | Products with stock   |
| **portfolio** | Projects, technologies, testimonials | Portfolio with filters|
| **business**  | Services, case studies, team     | Services, company     |

## 🔧 Prerequisites (Absolute Beginners Guide)

### ✅ What You Need to Install

**1. Docker Desktop**
```bash
# For macOS: Download from https://docker.com/products/docker-desktop
# For Windows: Download from https://docker.com/products/docker-desktop
# For Linux (Ubuntu/Debian):
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Verify installation:
docker --version
docker compose version
```

**2. Node.js (version 18 or higher)**
```bash
# For macOS: Download from https://nodejs.org/
# For Windows: Download from https://nodejs.org/
# For Linux (Ubuntu/Debian):
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation:
node --version
npm --version
```

**3. Python 3 (optional for helpers)**
```bash
# For macOS: pre-installed or use brew install python3
# For Windows: Download from https://python.org/downloads/
# For Linux: usually pre-installed
python3 --version
```

### 🚀 Step-by-Step Installation

**Step 1: Clone this repository**
```bash
# Using HTTPS (recommended for beginners)
git clone https://github.com/your-username/instant-wordpress-agents.git
cd instant-wordpress-agents

# Or using SSH if you have configured keys
git clone git@github.com:your-username/instant-wordpress-agents.git
cd instant-wordpress-agents
```

**Step 2: Set up environment file**
```bash
# Copy the example file
cp .env.example .env

# Edit .env file with your favorite editor
# nano .env  # On Linux/macOS
# notepad .env  # On Windows
```

**Step 3: Start local environment**
```bash
# Start WordPress containers
docker compose up -d

# Wait 30-60 seconds for WordPress to fully initialize
# Verify it works by visiting http://localhost:8080
```

**Step 4: Run healthcheck**
```bash
# Make script executable
chmod +x scripts/wp-healthcheck.sh

# Run verification
./scripts/wp-healthcheck.sh
```

**Step 5: In Claude Code, install Playwright MCP**
```bash
/install-playwright-mcp
```

### 🎯 First Use (You're ready!)
```bash
# In Claude Code, run:
/wp-one-shot project:"My First Blog" domain:"myblog.local" niche:"blog"
```

### 🚀 One-Command Setup (Alternative)
For an even simpler experience, run our automated setup:
```bash
# Download and run the complete setup
./scripts/wp-quick-start.sh
```
This script will:
- ✅ Check all prerequisites automatically
- ✅ Set up environment configuration
- ✅ Run integration guardrails
- ✅ Start WordPress containers
- ✅ Perform final health checks
- ✅ Guide you to your first site generation

Subagents handle everything automatically:
- ✅ Docker and local WordPress
- ✅ WP-CLI and tools
- ✅ Node.js for Playwright MCP
- ✅ Python 3 (optional, helpers only; native flow doesn't need it)

Note: `requirements.txt` is optional and only used for helpers; the native subagent flow does not require it.

## 📊 Guaranteed Outcome

After running the command, you get:

```
✅ Complete WordPress site at http://localhost:8080
✅ Zero 404 validated with Playwright MCP
✅ Basic SEO configured
✅ Security hardening applied
✅ Performance optimized
✅ Detailed reports generated
✅ Screenshots of all pages
✅ Ready for customization
```

## 🚀 Optional Deployment

```bash
# With automatic deployment to DigitalOcean
/wp-one-shot project:"My Site" domain:"mydomain.com" niche:"blog" deploy:true
```

Result:
- ✅ Droplet created on DigitalOcean
- ✅ Automatic SSL with Certbot
- ✅ Production site running with HTTPS
- ✅ Access credentials provided

## 📁 File Structure

```
.claude/agents/           # Specialized subagents
├── orchestrator.md      # Main coordinator
├── discovery.md         # Prerequisite validation
├── content-harvester.md # Content processing
├── schema-designer.md   # Information architecture
├── wp-builder.md        # Site construction
├── seo-optimizer.md     # SEO optimization
├── qa-validator.md      # Zero 404 validation
├── security-auditor.md  # Security hardening
├── performance-optimizer.md # Performance tuning
└── deployer.md          # Production deployment

artifacts/wp/            # Generated artifacts
├── schema/             # YAML specifications
├── reports/            # Quality reports

.claude/memory/         # State and recovery
├── project_context.json # Project context
├── datasets/           # Processed content
├── playwright/         # QA logs and screenshots
└── snapshots/          # Recovery points
```

## 🎉 Low/No-Code Philosophy

### ❌ What You DON’T Need
- WordPress technical knowledge
- Docker or WP-CLI experience
- Scripting or programming skills
- Manual prerequisite setup
- Intervention during the process

### ✅ What You Get
- **One command** = Working WordPress site
- **Intelligent subagents** handle everything complex
- **Automatic quality validation**
- **Automatic error recovery**
- **Detailed reports** for debugging

## 🔍 Verification Commands

```bash
# View generated reports
cat artifacts/wp/reports/validation.md
cat artifacts/wp/reports/security.md
cat artifacts/wp/reports/performance.md

# Run on-demand QA validation
/wp-validate

# See QA validation screenshots (Playwright MCP)
ls .claude/memory/playwright/screenshots/
```

## 🚨 Troubleshooting

### "Subagents not found"
```bash
# Subagents are in .claude/agents/
# Claude Code detects them automatically
/agents  # See all available subagents
```

### "Docker not working"
- Subagents check and handle Docker automatically
- If issues arise, they provide specific instructions

### "Zero 404 validation failed"
- Check `artifacts/wp/reports/validation.md`
- Subagents provide targeted solutions for each error

## 📚 More Documentation

- [Quick Start Guide](QUICK_START.md)
- [Subagent Architecture](docs/SUBAGENTS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🎯 Project Status

**✅ FUNCTIONAL** – Corrected architecture implemented

- ✅ Claude Code native subagents
- ✅ Low/no-code experience
- ✅ Automatic quality gates
- ✅ Error recovery
- ✅ Updated documentation

---

**Try it now!**

```bash
/wp-one-shot project:"My First Site" domain:"mysite.com" niche:"blog"
```

The subagents handle everything automatically. 🚀
