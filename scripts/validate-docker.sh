#!/usr/bin/env bash
set -euo pipefail

# ================================
# Docker Structure Validation Script
# ================================

echo "━━━━━━━━━━━━━━━━"
echo "🐳 Docker Structure Validation"
echo "━━━━━━━━━━━━━━━━"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERROR_COUNT=0

# Normalize Dockerfile (remove backslashes and join lines)
NORMALIZED_DOCKERFILE=$(sed ':a;N;$!ba;s/\\\n/ /g' "$PROJECT_ROOT/Dockerfile")

# Function to check Dockerfile element
check_dockerfile() {
    local pattern="$1"
    local description="$2"

    if echo "$NORMALIZED_DOCKERFILE" | grep -q "$pattern"; then
        echo "  - ✅ $description"
        return 0
    fi

    echo "  - ❌ Missing: $description"
    ((ERROR_COUNT++))
    return 1
}

# Function to check in raw Dockerfile (for labels and multi-line blocks)
check_dockerfile_raw() {
    local pattern="$1"
    local description="$2"

    if grep -q "$pattern" "$PROJECT_ROOT/Dockerfile"; then
        echo "  - ✅ $description"
        return 0
    fi

    echo "  - ❌ Missing: $description"
    ((ERROR_COUNT++))
    return 1
}

# Function to check environment variable exists
check_env_var() {
    local var_name="$1"
    local description="$2"

    if echo "$NORMALIZED_DOCKERFILE" | grep -q "${var_name}="; then
        echo "  - ✅ $description"
        return 0
    fi

    echo "  - ❌ Missing: $description"
    ((ERROR_COUNT++))
    return 1
}

# Validate Dockerfile exists
echo ""
echo "📁 Dockerfile Analysis:"
DOCKERFILE="$PROJECT_ROOT/Dockerfile"

if [[ ! -f "$DOCKERFILE" ]]; then
    echo "  - ❌ Dockerfile not found"
    ((ERROR_COUNT++))
    exit 1
fi

echo "  - ✅ Dockerfile exists"

# Check Dockerfile structure
echo ""
echo "Docker Targets:"
check_dockerfile_raw "AS base" "Base target"
check_dockerfile_raw "AS prod" "Production target"
check_dockerfile_raw "AS dev" "Development target"
check_dockerfile_raw "AS test" "Test target"

# Check base target requirements
echo ""
echo "Base Target Requirements:"
check_dockerfile_raw "FROM php:8.3-fpm-alpine AS base" "Uses correct base image"
check_dockerfile "adduser -u 1000" "Creates www user with UID 1000"
check_dockerfile "install -d.*var/lib/php/sessions" "Creates sessions directory"
check_dockerfile "install -d.*var/log/php" "Creates PHP log directory"
check_dockerfile_raw "WORKDIR /var/www/html" "Sets working directory"
check_dockerfile_raw "EXPOSE 9000" "Exposes port 9000"
check_dockerfile "COPY.*composer" "Installs Composer"

# Check scripts
echo ""
echo "Script Files:"
check_dockerfile_raw "scripts/entrypoint.sh" "Copies entrypoint script"
check_dockerfile_raw "scripts/healthcheck.sh" "Copies healthcheck script"
check_dockerfile_raw "chmod +x /usr/local/bin/\*.sh" "Makes scripts executable"

# Check health check
echo ""
echo "Health Check:"
check_dockerfile_raw "HEALTHCHECK" "Health check defined"
check_dockerfile_raw "CMD /usr/local/bin/healthcheck.sh" "Uses healthcheck script"

# Check PHP extensions installation (using normalized for multi-line RUN)
echo ""
echo "PHP Extensions:"
check_dockerfile "docker-php-ext-configure gd" "GD extension configured"
check_dockerfile "docker-php-ext-install.*zip" "ZIP extension installed"
check_dockerfile "docker-php-ext-install.*intl" "Intl extension installed"
check_dockerfile "docker-php-ext-install.*opcache" "OPcache extension installed"
check_dockerfile "docker-php-ext-install.*pdo_mysql" "PDO MySQL extension installed"
check_dockerfile "docker-php-ext-install.*bcmath" "BCMath extension installed"
check_dockerfile "pecl install redis" "Redis extension installed"

# Check production target
echo ""
echo "Production Target:"
check_dockerfile_raw "COPY --chown=root:root config/prod/php.ini" "Copies production PHP config"
check_dockerfile_raw "COPY --chown=root:root config/prod/fpm.conf" "Copies production FPM config"
check_dockerfile_raw "COPY --chown=root:root config/prod/opcache.ini" "Copies production OPcache config"
check_dockerfile_raw "USER www" "Switches to www user"

# Check development target
echo ""
echo "Development Target:"
check_dockerfile_raw "config/dev/php.ini" "Copies development PHP config"
check_dockerfile_raw "config/dev/xdebug.ini" "Copies Xdebug config"

# Check for development tools (using normalized)
if echo "$NORMALIZED_DOCKERFILE" | grep -q "apk add --no-cache.*git"; then
    echo "  - ✅ Development tools installed"
else
    echo "  - ❌ Development tools not found"
    ((ERROR_COUNT++))
fi

# Check Xdebug installation
if echo "$NORMALIZED_DOCKERFILE" | grep -q "pecl install xdebug"; then
    echo "  - ✅ Xdebug installed"
else
    echo "  - ❌ Xdebug not installed"
    ((ERROR_COUNT++))
fi

# Check test target
echo ""
echo "Test Target:"
check_dockerfile_raw "config/test/php.ini" "Copies test PHP config"
check_dockerfile_raw "config/test/pcov.ini" "Copies PCOV config"

# Check PCOV installation
if echo "$NORMALIZED_DOCKERFILE" | grep -q "pecl install pcov"; then
    echo "  - ✅ PCOV installed"
else
    echo "  - ❌ PCOV not installed"
    ((ERROR_COUNT++))
fi

# Check labels
echo ""
echo "Docker Labels:"
check_dockerfile_raw "LABEL maintainer" "Maintainer label"
check_dockerfile_raw "org.opencontainers.image.source" "Source URL label"
check_dockerfile_raw "org.opencontainers.image.licenses" "License label"

# Check build arguments
echo ""
echo "Build Arguments:"
check_dockerfile_raw "ARG REDIS_VERSION" "Redis version argument"
check_dockerfile_raw "ARG XDEBUG_VERSION" "Xdebug version argument"
check_dockerfile_raw "ARG PCOV_VERSION" "PCOV version argument"
check_dockerfile_raw "ARG IMAGE_VERSION" "Image version argument"
check_dockerfile_raw "ARG GIT_COMMIT" "Git commit argument"
check_dockerfile_raw "ARG BUILD_DATE" "Build date argument"

# Check environment variables
echo ""
echo "Environment Variables:"
check_env_var "BUILD_STAGE" "Build stage environment variable"
check_env_var "IMAGE_VERSION" "Image version environment variable"
check_env_var "GIT_COMMIT" "Git commit environment variable"
check_env_var "BUILD_DATE" "Build date environment variable"
check_env_var "REDIS_VERSION" "Redis version environment variable"

# Validate configuration files referenced in Dockerfile exist
echo ""
echo "Configuration File Validation:"
config_files=(
    "config/prod/php.ini"
    "config/prod/fpm.conf"
    "config/prod/opcache.ini"
    "config/dev/php.ini"
    "config/dev/xdebug.ini"
    "config/test/php.ini"
    "config/test/pcov.ini"
)

for config_file in "${config_files[@]}"; do
    if [[ -f "$PROJECT_ROOT/$config_file" ]]; then
        echo "  - ✅ $config_file exists"
    else
        echo "  - ❌ $config_file missing"
        ((ERROR_COUNT++))
    fi
done

# Validate scripts referenced in Dockerfile exist
echo ""
echo "Script File Validation:"
script_files=(
    "scripts/entrypoint.sh"
    "scripts/healthcheck.sh"
)

for script_file in "${script_files[@]}"; do
    if [[ -f "$PROJECT_ROOT/$script_file" ]]; then
        if [[ -x "$PROJECT_ROOT/$script_file" ]]; then
            echo "  - ✅ $script_file exists and executable"
        else
            echo "  - ⚠️  $script_file exists but not executable"
        fi
    else
        echo "  - ❌ $script_file missing"
        ((ERROR_COUNT++))
    fi
done

# Check for proper entrypoint and command
echo ""
echo "Entrypoint and Command:"
if grep -q "ENTRYPOINT.*entrypoint.sh" "$PROJECT_ROOT/Dockerfile"; then
    echo "  - ✅ Entrypoint set to entrypoint.sh"
else
    echo "  - ❌ Entrypoint not properly set"
    ((ERROR_COUNT++))
fi

if grep -q "CMD.*php-fpm" "$PROJECT_ROOT/Dockerfile"; then
    echo "  - ✅ Default command set to php-fpm"
else
    echo "  - ❌ Default command not set"
    ((ERROR_COUNT++))
fi

# Additional security checks
echo ""
echo "Security Best Practices:"
if echo "$NORMALIZED_DOCKERFILE" | grep -q "apk del.*build-deps"; then
    echo "  - ✅ Build dependencies cleaned up"
else
    echo "  - ⚠️  Build dependencies not cleaned"
fi

if echo "$NORMALIZED_DOCKERFILE" | grep -q "rm -rf.*pear.*cache"; then
    echo "  - ✅ Temporary files cleaned"
else
    echo "  - ⚠️  Temporary files may remain"
fi

# Check directory permissions
echo ""
echo "Directory Permissions:"
if echo "$NORMALIZED_DOCKERFILE" | grep -q "install -d -m 0755 -o www -g www"; then
    echo "  - ✅ Directories created with proper permissions"
else
    echo "  - ⚠️  Directory permissions may need review"
fi

echo ""
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "✅ Docker structure validation passed"
    echo "━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ Docker structure validation failed with $ERROR_COUNT error(s)"
    echo "━━━━━━━━━━━━━━━━"
    exit 1
fi
