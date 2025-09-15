#!/usr/bin/env bash
set -euo pipefail

# WordPress Quick Start - Complete setup automation
# This script guides beginners through the entire setup process

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                   WordPress Quick Start Setup                    ║"
    echo "║              Automated setup for absolute beginners             ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

step_header() {
    echo -e "\n${CYAN}█ STEP $1: $2${NC}"
    echo -e "${CYAN}$(printf '=%.0s' $(seq 1 60))${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️ WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

prompt_continue() {
    echo -e "\n${YELLOW}Press Enter to continue or Ctrl+C to exit...${NC}"
    read -r
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

print_banner

info "This script will guide you through setting up WordPress One-Shot Generator"
info "Estimated time: 3-5 minutes"
prompt_continue

# Step 1: Verify Prerequisites
step_header "1" "Checking Prerequisites"

prerequisites_missing=0

echo "Checking system requirements..."

# Docker
if check_command docker; then
    success "Docker is installed"
    if docker info >/dev/null 2>&1; then
        success "Docker daemon is running"
    else
        error "Docker daemon is not running"
        info "Please start Docker Desktop and run this script again"
        exit 1
    fi
else
    error "Docker is not installed"
    info "Download from: https://docker.com/products/docker-desktop"
    ((prerequisites_missing++))
fi

# Node.js
if check_command node; then
    node_version=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$node_version" -ge 18 ]; then
        success "Node.js v$node_version (>= 18 required)"
    else
        error "Node.js version too old: v$node_version (>= 18 required)"
        info "Download from: https://nodejs.org/"
        ((prerequisites_missing++))
    fi
else
    error "Node.js is not installed"
    info "Download from: https://nodejs.org/"
    ((prerequisites_missing++))
fi

# NPM
if check_command npm; then
    success "NPM is available"
else
    error "NPM is not available (usually comes with Node.js)"
    ((prerequisites_missing++))
fi

# Python 3 (optional)
if check_command python3; then
    success "Python 3 is available (optional)"
else
    warn "Python 3 not found (optional, but recommended for deployment features)"
fi

if [ $prerequisites_missing -gt 0 ]; then
    error "$prerequisites_missing prerequisite(s) missing. Please install them first."
    exit 1
fi

success "All prerequisites are satisfied!"

# Step 2: Environment Setup
step_header "2" "Environment Configuration"

if [ ! -f "$ROOT_DIR/.env" ]; then
    info "Creating .env file from template..."
    if [ -f "$ROOT_DIR/.env.example" ]; then
        cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
        success ".env file created"
        
        echo -e "\n${YELLOW}IMPORTANT: Edit the .env file with your preferred settings:${NC}"
        echo "- DO_API_TOKEN: Your DigitalOcean token (for deployment)"
        echo "- SSH_HOST: Your server IP"
        echo "- DOMAIN: Your domain name"
        echo "- Other deployment settings"
        echo ""
        echo -e "${BLUE}You can edit it now or later with:${NC}"
        echo -e "${CYAN}nano .env${NC} (Linux/macOS) or ${CYAN}notepad .env${NC} (Windows)"
        
        echo -e "\n${YELLOW}Do you want to edit .env now? [y/N]${NC}"
        read -r edit_env
        if [[ $edit_env =~ ^[Yy]$ ]]; then
            if check_command nano; then
                nano "$ROOT_DIR/.env"
            elif check_command vim; then
                vim "$ROOT_DIR/.env"
            elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                notepad "$ROOT_DIR/.env"
            else
                info "Please edit $ROOT_DIR/.env with your favorite text editor"
                prompt_continue
            fi
        fi
    else
        error ".env.example not found"
        exit 1
    fi
else
    success ".env file already exists"
fi

# Step 3: Make Scripts Executable
step_header "3" "Preparing Scripts"

scripts_to_make_executable=(
    "wp-healthcheck.sh"
    "wp-integration-guardrails.sh" 
    "wp-security-check.sh"
    "wp-post-deploy-checks.sh"
)

for script in "${scripts_to_make_executable[@]}"; do
    if [ -f "$ROOT_DIR/scripts/$script" ]; then
        chmod +x "$ROOT_DIR/scripts/$script"
        success "$script is now executable"
    else
        warn "$script not found"
    fi
done

# Step 4: Run Integration Guardrails
step_header "4" "Running Integration Guardrails"

if [ -x "$ROOT_DIR/scripts/wp-integration-guardrails.sh" ]; then
    info "Running comprehensive system validation..."
    
    if "$ROOT_DIR/scripts/wp-integration-guardrails.sh"; then
        success "All integration guardrails passed!"
    else
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            warn "Some warnings detected, but system should work"
            info "Check the report at: artifacts/wp/reports/integration-guardrails.md"
        else
            error "Critical issues detected. Please resolve them first."
            exit 1
        fi
    fi
else
    error "Integration guardrails script not found or not executable"
    exit 1
fi

# Step 5: Start WordPress Environment
step_header "5" "Starting WordPress Environment"

info "Starting Docker containers..."
if docker compose up -d; then
    success "Docker containers started"
    
    info "Waiting for WordPress to initialize (30 seconds)..."
    sleep 30
    
    # Check if WordPress is accessible
    if curl -s -f http://localhost:8080 >/dev/null; then
        success "WordPress is running at http://localhost:8080"
    else
        warn "WordPress may still be initializing. Please wait a moment and check http://localhost:8080"
    fi
else
    error "Failed to start Docker containers"
    exit 1
fi

# Step 6: Final Health Check
step_header "6" "Final Health Check"

if [ -x "$ROOT_DIR/scripts/wp-healthcheck.sh" ]; then
    "$ROOT_DIR/scripts/wp-healthcheck.sh"
    success "Health check completed"
else
    warn "Health check script not found"
fi

# Success Message
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                        SETUP COMPLETE!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${CYAN}🎉 Your WordPress development environment is ready!${NC}\n"

echo -e "${BLUE}Next Steps:${NC}"
echo -e "${CYAN}1.${NC} Open Claude Code"
echo -e "${CYAN}2.${NC} Run: ${YELLOW}/install-playwright-mcp${NC}"
echo -e "${CYAN}3.${NC} Generate your first site:"
echo -e "   ${YELLOW}/wp-one-shot project:\"My Blog\" domain:\"myblog.local\" niche:\"blog\"${NC}"

echo -e "\n${BLUE}Useful commands:${NC}"
echo -e "${CYAN}•${NC} Check WordPress: ${YELLOW}http://localhost:8080${NC}"
echo -e "${CYAN}•${NC} View health: ${YELLOW}./scripts/wp-healthcheck.sh${NC}"
echo -e "${CYAN}•${NC} Security check: ${YELLOW}./scripts/wp-security-check.sh${NC}"
echo -e "${CYAN}•${NC} View logs: ${YELLOW}docker compose logs -f${NC}"
echo -e "${CYAN}•${NC} Stop containers: ${YELLOW}docker compose down${NC}"

echo -e "\n${GREEN}Happy WordPress building! 🚀${NC}"