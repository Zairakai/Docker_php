#!/usr/bin/env bash
set -euo pipefail

# ================================
# Security Validation Script
# ================================

echo "━━━━━━━━━━━━━━━━"
echo "🔒 Security Configuration Validation"
echo "━━━━━━━━━━━━━━━━"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERROR_COUNT=0

# Function to check security setting
check_security() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    local expected_value="${4:-}"

    if grep -q "$pattern" "$file"; then
        if [[ -n "$expected_value" ]]; then
            # Check for specific value
            if grep -q "$pattern.*$expected_value" "$file"; then
                echo "  - ✅ $description: $expected_value"
                return 0
            else
                echo "  - ❌ $description: Incorrect value (expected: $expected_value)"
                ((ERROR_COUNT++))
                return 1
            fi
        else
            echo "  - ✅ $description"
            return 0
        fi
    else
        echo "  - ❌ Missing: $description"
        ((ERROR_COUNT++))
        return 1
    fi
}

# Function to check disabled functions
check_disabled_functions() {
    local file="$1"
    local functions_to_check=("exec" "passthru" "shell_exec" "system" "proc_open" "popen")

    echo ""
    echo "Checking disabled dangerous functions..."

    if ! grep -q "disable_functions" "$file"; then
        echo "  - ❌ disable_functions not configured"
        ((ERROR_COUNT++))
        return 1
    fi

    for func in "${functions_to_check[@]}"; do
        if grep -q "disable_functions.*$func" "$file"; then
            echo "  - ✅ $func disabled"
        else
            echo "  - ❌ $func not disabled"
            ((ERROR_COUNT++))
        fi
    done
}

# Check production security settings
echo ""
echo "Production Security Analysis:"
PROD_PHP="$PROJECT_ROOT/config/prod/php.ini"
PROD_FPM="$PROJECT_ROOT/config/prod/fpm.conf"

if [[ -f "$PROD_PHP" ]]; then
    check_security "$PROD_PHP" "allow_url_fopen" "URL file access" "Off"
    check_security "$PROD_PHP" "expose_php" "PHP version exposure" "Off"
    check_security "$PROD_PHP" "allow_url_include" "URL include" "Off"
    check_security "$PROD_PHP" "open_basedir" "File access restriction"
    check_disabled_functions "$PROD_PHP"

    # Session security
    check_security "$PROD_PHP" "session.cookie_secure" "Session cookie secure flag" "On"
    check_security "$PROD_PHP" "session.cookie_httponly" "Session cookie HTTPOnly" "On"
    check_security "$PROD_PHP" "session.cookie_samesite" "Session cookie SameSite" "Strict"
    check_security "$PROD_PHP" "session.use_strict_mode" "Strict session mode" "On"
else
    echo "  - ❌ Production PHP configuration not found"
    ((ERROR_COUNT++))
fi

# Check FPM security settings
if [[ -f "$PROD_FPM" ]]; then
    echo ""
    echo "FPM Security Analysis:"
    check_security "$PROD_FPM" "user = www" "FPM user"
    check_security "$PROD_FPM" "group = www" "FPM group"
    check_security "$PROD_FPM" "clear_env" "Environment clearing" "yes"
    check_security "$PROD_FPM" "php_flag\[display_errors\] = off" "Error display in FPM"
    check_security "$PROD_FPM" "php_admin_flag\[log_errors\] = on" "Error logging in FPM"
else
    echo "  - ❌ Production FPM configuration not found"
    ((ERROR_COUNT++))
fi

# Check Dockerfile security aspects
echo ""
echo "Docker Security Analysis:"
DOCKERFILE="$PROJECT_ROOT/Dockerfile"

if [[ -f "$DOCKERFILE" ]]; then
    # Check for non-root user
    if grep -q "adduser -u 1000" "$DOCKERFILE"; then
        echo "  - ✅ Non-root user created with UID 1000"
    else
        echo "  - ❌ Non-root user not properly configured"
        ((ERROR_COUNT++))
    fi

    # Check for user switching
    if grep -A11 "FROM base AS prod" "$DOCKERFILE" | grep -q "USER www"; then
        echo "  - ✅ Production target switches to www user"
    else
        echo "  - ❌ Production target does not switch to www user"
        ((ERROR_COUNT++))
    fi

    # Check for file permissions
    if grep -q "chmod +x /usr/local/bin/\*.sh" "$DOCKERFILE"; then
        echo "  - ✅ Script permissions set correctly"
    else
        echo "  - ❌ Script permissions not set"
        ((ERROR_COUNT++))
    fi

    # Check for proper file ownership
    if grep -q "COPY --chown=root:root" "$DOCKERFILE"; then
        echo "  - ✅ Configuration files owned by root"
    else
        echo "  - ❌ Configuration file ownership not specified"
        ((ERROR_COUNT++))
    fi
else
    echo "  - ❌ Dockerfile not found"
    ((ERROR_COUNT++))
fi

# Security recommendations analysis
echo ""
echo "Security Recommendations:"

# Check if development has relaxed security (which is expected)
DEV_PHP="$PROJECT_ROOT/config/dev/php.ini"
if [[ -f "$DEV_PHP" ]]; then
    if grep -q "allow_url_fopen = On" "$DEV_PHP"; then
        echo "  - ℹ️  Development allows URL access (expected)"
    fi

    if grep -q "display_errors = On" "$DEV_PHP"; then
        echo "  - ℹ️  Development displays errors (expected)"
    fi
fi

# Check if OPcache is properly secured for production
OPCACHE_INI="$PROJECT_ROOT/config/prod/opcache.ini"
if [[ -f "$OPCACHE_INI" ]]; then
    if grep -q "opcache.validate_timestamps = 0" "$OPCACHE_INI"; then
        echo "  - ✅ OPcache timestamp validation disabled in production"
    else
        echo "  ⚠️  Consider disabling OPcache timestamp validation in production"
    fi
fi

echo ""
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🔒 All security configurations passed validation"
    echo "━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ Security validation failed with $ERROR_COUNT issue(s)"
    echo "━━━━━━━━━━━━━━━━"
    exit 1
fi
