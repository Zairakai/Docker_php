#!/usr/bin/env bash
# Zairakai Laravel Dev Tools - Central Configuration
# This file is sourced by all scripts to maintain consistency

set -euo pipefail

# ================================
# COLORS
# ================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export NC='\033[0m'

# Backwards compatibility aliases
export COLOR_RED="$RED"
export COLOR_GREEN="$GREEN"
export COLOR_YELLOW="$YELLOW"
export COLOR_BLUE="$BLUE"
export COLOR_CYAN="$CYAN"
export COLOR_MAGENTA="$MAGENTA"
export COLOR_RESET="$NC"

# ================================
# ENVIRONMENT DETECTION
# ================================
export IS_CI="${CI:-false}"
export IS_GITLAB_CI="${GITLAB_CI:-false}"
export IS_GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"

# ================================
# GIT DETECTION
# ================================
export HAS_GIT=false
if [[ -d "${PROJECT_ROOT}/.git" ]]; then
    export HAS_GIT=true
fi

# ================================
# HELPER FUNCTIONS
# ================================

# Print colored message
log_info() {
    echo -e "${CYAN}ℹ ${NC}$*"
}

log_success() {
    echo -e "${GREEN}✅ ${NC}$*"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$*"
}

log_error() {
    echo -e "${RED}❌ ${NC}$*"
}

log_step() {
    echo -e "${BLUE}→${NC} $*"
}

log_header() {
    echo ""
    echo -e "${MAGENTA}════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $*${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════${NC}"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_step "Created directory: $dir"
    fi
}

# ================================
# ADVANCED PATTERNS
# ================================

# Pattern 1: Error Counter for Multi-Check Scripts
# Usage:
#   init_error_counter
#   run_check "Code Style" "bash scripts/cs-check.sh" || increment_error_counter
#   run_check "PHPStan" "bash scripts/phpstan.sh" || increment_error_counter
#   exit_with_error_count "Quality Checks"
#
ERROR_COUNT=0

init_error_counter() {
    ERROR_COUNT=0
}

increment_error_counter() {
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

get_error_count() {
    echo "$ERROR_COUNT"
}

exit_with_error_count() {
    local check_name="${1:-Checks}"

    if [[ $ERROR_COUNT -eq 0 ]]; then
        log_header "✅ All ${check_name} Passed"
        return 0
    else
        log_header "❌ ${ERROR_COUNT} ${check_name} Failed"
        return 1
    fi
}

# Run a check with error tracking
# Usage: run_check "Check Name" "command to run"
run_check() {
    local check_name="$1"
    local check_command="$2"

    log_info "Running: ${check_name}"

    if eval "$check_command"; then
        log_success "${check_name} passed"
        return 0
    else
        log_error "${check_name} failed"
        increment_error_counter
        return 1
    fi
}

# Cleanup temporary files
cleanup_temp_files() {
    true;
}

# Setup signal handlers for cleanup
trap cleanup_temp_files EXIT INT TERM

# ================================
# VALIDATION
# ================================

# Ensure we're in project root
cd "$PROJECT_ROOT"
