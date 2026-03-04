#!/usr/bin/env bash
set -euo pipefail

# ================================
# Complete Project Validation Script
# ================================

echo "━━━━━━━━━━━━━━━━"
echo "🔧 Complete Project Validation"
echo "━━━━━━━━━━━━━━━━"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Run all validation scripts
echo "📋 Running configuration validation..."
if "${PROJECT_ROOT}/scripts/validate-config.sh"; then
    echo "✅ Configuration validation passed"
else
    echo "❌ Configuration validation failed"
    exit 1
fi

echo ""
echo "🔒 Running security validation..."
if "${PROJECT_ROOT}/scripts/validate-security.sh"; then
    echo "✅ Security validation passed"
else
    echo "❌ Security validation failed"
    exit 1
fi

echo ""
echo "🐳 Running Docker structure validation..."
if "${PROJECT_ROOT}/scripts/validate-docker.sh"; then
    echo "✅ Docker structure validation passed"
else
    echo "❌ Docker structure validation failed"
    exit 1
fi

echo ""
echo "🧪 Running BATS tests..."
if cd "$PROJECT_ROOT" && make bats; then
    echo "✅ BATS tests passed"
else
    echo "❌ BATS tests failed"
    exit 1
fi

echo ""
echo "🎉 All project validations passed successfully!"
echo "━━━━━━━━━━━━━━━━"
