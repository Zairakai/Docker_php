#!/usr/bin/env bash
set -euo pipefail

# ================================
# Configuration Validation Script
# ================================

echo "━━━━━━━━━━━━━━━━"
echo "🔧 Configuration Files Validation"
echo "━━━━━━━━━━━━━━━━"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERROR_COUNT=0

# Function to validate configuration file
validate_config() {
    local file="$1"
    local description="$2"

    if [[ ! -f "$file" ]]; then
        echo "  ❌ File not found: $file"
        ((ERROR_COUNT++))
        return 1
    fi

    # Test PHP syntax for .ini files
    if [[ "$file" == *.ini ]]; then
        if php -l "$file" >/dev/null 2>&1; then
            echo "  - ✅ $description"
        else
            echo "  - ❌ $description"
            ((ERROR_COUNT++))
            return 1
        fi
    fi

    return 0
}

# Function to check security setting
check_security_setting() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -q "$pattern" "$file"; then
        echo "  - ✅ $description"
        return 0
    else
        echo "  - ❌ Missing: $description"
        ((ERROR_COUNT++))
        return 1
    fi
}

# Validate production configuration files
echo ""
echo "Production Configuration:"
validate_config "$PROJECT_ROOT/config/prod/php.ini" "php.ini"
validate_config "$PROJECT_ROOT/config/prod/fpm.conf" "fpm.conf"
validate_config "$PROJECT_ROOT/config/prod/opcache.ini" "opcache.ini"

# Check critical security settings in production
echo ""
echo "Production Security Settings:"
check_security_setting "$PROJECT_ROOT/config/prod/php.ini" "allow_url_fopen = Off" "URL file access disabled"
check_security_setting "$PROJECT_ROOT/config/prod/php.ini" "expose_php = Off" "PHP version hidden"
check_security_setting "$PROJECT_ROOT/config/prod/php.ini" "disable_functions" "Dangerous functions disabled"
check_security_setting "$PROJECT_ROOT/config/prod/php.ini" "open_basedir" "File access restricted"

# Validate development configuration files
echo ""
echo "Development Configuration:"
validate_config "$PROJECT_ROOT/config/dev/php.ini" "php.ini"
validate_config "$PROJECT_ROOT/config/dev/xdebug.ini" "xdebug.ini"

# Check development-specific settings
echo ""
echo "Development Settings:"
check_security_setting "$PROJECT_ROOT/config/dev/php.ini" "allow_url_fopen = On" "URL file access enabled"
check_security_setting "$PROJECT_ROOT/config/dev/php.ini" "display_errors = On" "Error display enabled"

# Validate test configuration files
echo ""
echo "Test Configuration:"
validate_config "$PROJECT_ROOT/config/test/php.ini" "php.ini"
validate_config "$PROJECT_ROOT/config/test/pcov.ini" "pcov.ini"

# Check test-specific settings
echo ""
echo "Test Settings:"
check_security_setting "$PROJECT_ROOT/config/test/pcov.ini" "pcov.enabled = 1" "PCOV coverage enabled"

# Validate FPM configuration consistency
echo ""
echo "FPM Configuration:"
if [[ -f "$PROJECT_ROOT/config/prod/fpm.conf" ]]; then
    check_security_setting "$PROJECT_ROOT/config/prod/fpm.conf" "pm = dynamic" "Dynamic process manager"
    check_security_setting "$PROJECT_ROOT/config/prod/fpm.conf" "user = www" "Non-root user configuration"
    check_security_setting "$PROJECT_ROOT/config/prod/fpm.conf" "clear_env = yes" "Environment clearing"
fi

# Validate OPcache configuration consistency
echo ""
echo "OPcache Configuration:"
if [[ -f "$PROJECT_ROOT/config/prod/opcache.ini" ]]; then
    check_security_setting "$PROJECT_ROOT/config/prod/opcache.ini" "opcache.enable = 1" "OPcache enabled"
    check_security_setting "$PROJECT_ROOT/config/prod/opcache.ini" "opcache.validate_timestamps = 0" "Timestamp validation disabled"
    check_security_setting "$PROJECT_ROOT/config/prod/opcache.ini" "opcache.jit_buffer_size" "JIT compilation enabled"
fi

echo ""
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 All configuration files passed validation"
    echo "━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ Validation failed with $ERROR_COUNT error(s)"
    echo "━━━━━━━━━━━━━━━━"
    exit 1
fi
