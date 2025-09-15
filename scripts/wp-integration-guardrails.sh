#!/usr/bin/env bash
set -euo pipefail

# WordPress Integration Guardrails
# Ensures seamless integration by validating all critical components

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
REPORT_DIR="$ROOT_DIR/artifacts/wp/reports"
REPORT_FILE="$REPORT_DIR/integration-guardrails.md"
mkdir -p "$REPORT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { 
    echo -e "$1" | tee -a "$REPORT_FILE"
}

error() {
    echo -e "${RED}❌ ERROR: $1${NC}" | tee -a "$REPORT_FILE"
}

warn() {
    echo -e "${YELLOW}⚠️ WARNING: $1${NC}" | tee -a "$REPORT_FILE"
}

success() {
    echo -e "${GREEN}✅ SUCCESS: $1${NC}" | tee -a "$REPORT_FILE"
}

info() {
    echo -e "ℹ️ INFO: $1" | tee -a "$REPORT_FILE"
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        success "$1 is available"
        return 0
    else
        error "$1 is not installed or not in PATH"
        return 1
    fi
}

check_port_available() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        warn "Port $port is already in use"
        return 1
    else
        success "Port $port is available"
        return 0
    fi
}

check_docker_service() {
    if docker info >/dev/null 2>&1; then
        success "Docker daemon is running"
        return 0
    else
        error "Docker daemon is not running. Please start Docker Desktop"
        return 1
    fi
}

check_node_version() {
    local required_version="18"
    if command -v node >/dev/null 2>&1; then
        local current_version=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$current_version" -ge "$required_version" ]; then
            success "Node.js version $current_version >= $required_version"
            return 0
        else
            error "Node.js version $current_version < $required_version. Please upgrade"
            return 1
        fi
    else
        error "Node.js is not installed"
        return 1
    fi
}

check_disk_space() {
    local required_gb=5
    local available_gb=$(df -BG "$ROOT_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [ "$available_gb" -ge "$required_gb" ]; then
        success "Sufficient disk space: ${available_gb}GB available (${required_gb}GB required)"
        return 0
    else
        error "Insufficient disk space: ${available_gb}GB available, ${required_gb}GB required"
        return 1
    fi
}

check_memory() {
    local required_mb=2048
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local total_mb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024)}')
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local total_mb=$(free -m | awk 'NR==2{print $2}')
    else
        warn "Cannot check memory on this platform"
        return 0
    fi
    
    if [ "$total_mb" -ge "$required_mb" ]; then
        success "Sufficient memory: ${total_mb}MB available (${required_mb}MB required)"
        return 0
    else
        error "Insufficient memory: ${total_mb}MB available, ${required_mb}MB required"
        return 1
    fi
}

check_network_connectivity() {
    if ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
        success "Network connectivity OK"
        return 0
    else
        error "No internet connectivity detected"
        return 1
    fi
}

check_env_file() {
    if [ -f "$ROOT_DIR/.env" ]; then
        success ".env file exists"
        
        # Check for required variables with placeholders
        local required_vars=("DO_API_TOKEN" "SSH_HOST" "DOMAIN" "SSH_USER" "SSH_KEY" "WP_PATH")
        local missing_vars=()
        
        for var in "${required_vars[@]}"; do
            if grep -q "^${var}=" "$ROOT_DIR/.env"; then
                local value=$(grep "^${var}=" "$ROOT_DIR/.env" | cut -d'=' -f2-)
                if [ -z "$value" ] || [ "$value" = "YOUR_IP" ] || [ "$value" = "example.com" ]; then
                    missing_vars+=("$var")
                fi
            else
                missing_vars+=("$var")
            fi
        done
        
        if [ ${#missing_vars[@]} -eq 0 ]; then
            success "All required environment variables are configured"
            return 0
        else
            warn "Environment variables need configuration: ${missing_vars[*]}"
            info "Run 'cp .env.example .env' and edit the values"
            return 1
        fi
    else
        error ".env file not found"
        info "Run 'cp .env.example .env' to create it"
        return 1
    fi
}

check_docker_compose_file() {
    if [ -f "$ROOT_DIR/docker-compose.yml" ] || [ -f "$ROOT_DIR/compose.yml" ]; then
        success "Docker Compose file found"
        return 0
    else
        error "No docker-compose.yml or compose.yml file found"
        return 1
    fi
}

check_wp_container_health() {
    if docker ps --format '{{.Names}}' | grep -q '^wp-dev$'; then
        if docker exec wp-dev wp --allow-root core version >/dev/null 2>&1; then
            local wp_version=$(docker exec wp-dev wp --allow-root core version)
            success "WordPress container is healthy (version $wp_version)"
            return 0
        else
            error "WordPress container is running but WP-CLI is not working"
            return 1
        fi
    else
        warn "WordPress container 'wp-dev' is not running"
        info "Run 'docker compose up -d' to start it"
        return 1
    fi
}

check_playwright_mcp() {
    if npx @playwright/mcp@latest --help >/dev/null 2>&1; then
        success "Playwright MCP is available"
        return 0
    else
        warn "Playwright MCP not available"
        info "Run '/install-playwright-mcp' in Claude Code"
        return 1
    fi
}

check_file_permissions() {
    local critical_files=("scripts/wp-healthcheck.sh" "scripts/wp-security-check.sh")
    local permission_issues=0
    
    for file in "${critical_files[@]}"; do
        if [ -f "$ROOT_DIR/$file" ]; then
            if [ -x "$ROOT_DIR/$file" ]; then
                success "$file is executable"
            else
                warn "$file is not executable"
                info "Run 'chmod +x $file' to fix"
                ((permission_issues++))
            fi
        else
            error "$file not found"
            ((permission_issues++))
        fi
    done
    
    return $permission_issues
}

check_security_baseline() {
    info "Running security baseline check..."
    
    # Check for common security issues
    local security_issues=0
    
    # Check if running as root (not recommended)
    if [ "$EUID" -eq 0 ]; then
        warn "Running as root is not recommended for development"
        ((security_issues++))
    fi
    
    # Check for default passwords in .env
    if [ -f "$ROOT_DIR/.env" ]; then
        if grep -q "password123\|admin\|test123" "$ROOT_DIR/.env"; then
            error "Default or weak passwords detected in .env"
            ((security_issues++))
        fi
    fi
    
    if [ $security_issues -eq 0 ]; then
        success "Security baseline checks passed"
    fi
    
    return $security_issues
}

# Initialize report
: > "$REPORT_FILE"
log "# WordPress Integration Guardrails Report"
log "Generated: $(date)"
log ""

# Track overall status
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

run_check() {
    local check_name="$1"
    local check_function="$2"
    
    log "## $check_name"
    ((TOTAL_CHECKS++))
    
    if $check_function; then
        ((PASSED_CHECKS++))
    else
        local exit_code=$?
        if [ $exit_code -eq 1 ]; then
            ((WARNING_CHECKS++))
        else
            ((FAILED_CHECKS++))
        fi
    fi
    log ""
}

# Execute all checks
log "# System Prerequisites"
run_check "Docker Installation" "check_command docker"
run_check "Docker Compose" "check_command docker-compose || command -v docker >/dev/null && docker compose version >/dev/null 2>&1"
run_check "Node.js Installation" "check_command node"
run_check "NPM Installation" "check_command npm"
run_check "Python 3 Installation" "check_command python3"

log "# System Resources"
run_check "Docker Service" check_docker_service
run_check "Node.js Version" check_node_version
run_check "Disk Space" check_disk_space
run_check "Memory" check_memory
run_check "Network Connectivity" check_network_connectivity

log "# Project Configuration"
run_check "Environment File" check_env_file
run_check "Docker Compose File" check_docker_compose_file
run_check "File Permissions" check_file_permissions

log "# Service Health"
run_check "Port 8080 Availability" "check_port_available 8080"
run_check "WordPress Container" check_wp_container_health
run_check "Playwright MCP" check_playwright_mcp

log "# Security"
run_check "Security Baseline" check_security_baseline

# Generate summary
log "# Summary"
log "- Total checks: $TOTAL_CHECKS"
log "- Passed: $PASSED_CHECKS ✅"
log "- Warnings: $WARNING_CHECKS ⚠️"
log "- Failed: $FAILED_CHECKS ❌"
log ""

if [ $FAILED_CHECKS -eq 0 ] && [ $WARNING_CHECKS -eq 0 ]; then
    success "All integration guardrails passed! System is ready for WordPress generation."
    log ""
    log "🚀 You can now run:"
    log '```bash'
    log '/wp-one-shot project:"My Site" domain:"mysite.local" niche:"blog"'
    log '```'
    exit 0
elif [ $FAILED_CHECKS -eq 0 ]; then
    warn "System has warnings but should work. Review warnings above."
    log ""
    log "🚀 You can proceed with:"
    log '```bash'
    log '/wp-one-shot project:"My Site" domain:"mysite.local" niche:"blog"'
    log '```'
    exit 0
else
    error "Critical issues detected. Please resolve failed checks before proceeding."
    log ""
    log "❌ Fix the failed checks above before running wp-one-shot"
    exit 1
fi