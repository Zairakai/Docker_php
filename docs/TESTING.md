# Testing Documentation

This document explains the testing strategy and how to run tests for this Docker image project.

## 🧪 Test Structure

The project uses multiple testing approaches to ensure image quality:

### BATS Tests (Core Testing Framework)

- **Unit Tests** (`tests/unit/`) - Test individual components
- **Integration Tests** (`tests/integration/`) - Test Docker structure and configuration
- **Security Tests** (`tests/security/`) - Validate security configurations
- **Performance Tests** (`tests/performance/`) - Check performance settings

### Shell Script Tests

- **Image Tests** (`tests/test-*.sh`) - Test actual Docker images
- **Common Tests** (`tests/test-common.sh`) - Shared validation logic

## 🏃 Running Tests

### Quick Tests

```bash
# Run basic validation (fastest)
make quick-test

# Test Dockerfile structure
make validate-dockerfile

# Test script executability
make test-essential-scripts
```

### Comprehensive Testing

```bash
# Run all local tests (no Docker required)
make test-local

# Test all configuration files
make test-config

# Validate security settings
make test-security

# Validate Docker structure
make test-docker

# Run complete validation suite
make test-complete
```

### Docker Image Testing (Requires Docker)

```bash
# Test all three image targets
make test-image

# Test specific targets
make test-prod
make test-dev
make test-test
```

### BATS Framework Testing

```bash
# Run all BATS tests
make bats

# Run specific test categories
bats tests/unit/
bats tests/integration/
bats tests/security/
bats tests/performance/
```

## 📋 Test Categories Explained

### Configuration Tests (`tests/integration/20-configuration.bats`)

Validates:

- ✅ All configuration files exist and have correct syntax
- ✅ Production security settings are properly configured
- ✅ Development settings allow debugging
- ✅ OPcache configuration is optimized
- ✅ Session security is enabled

### Docker Structure Tests (`tests/integration/21-docker-targets.bats`)

Validates:

- ✅ All three Docker targets (prod/dev/test) exist
- ✅ Each target copies appropriate configuration files
- ✅ Non-root user configuration is correct
- ✅ Required directories are created
- ✅ Health check is properly configured

### Security Tests (`tests/security/10-security-hardening.bats`)

Validates:

- ✅ Dangerous functions are disabled in production
- ✅ File access is restricted with open_basedir
- ✅ PHP version is hidden
- ✅ Session security settings are enabled
- ✅ Container runs as non-root user

### Performance Tests (`tests/performance/`)

Validates:

- ✅ OPcache is enabled and optimized
- ✅ JIT compilation is configured
- ✅ FPM process manager is tuned
- ✅ Memory settings are appropriate

### Script Tests (`tests/unit/`)

Validates:

- ✅ Scripts exist and are executable
- ✅ Scripts use proper error handling
- ✅ Scripts can be sourced without errors

## 🔄 Testing Workflow

### Before Commit

```bash
# Quick validation
make test-local

# This runs:
# - Dockerfile structure validation
# - Script executability checks
# - Configuration file validation
# - Security validation
```

### After Major Changes

```bash
# Complete validation
make test-complete

# This includes:
# - All BATS tests
# - All configuration validation
# - All security checks
# - Docker structure validation
```

### Before Tagging Release

```bash
# Full testing with Docker (if Docker available)
make test-image

# Or use CI pipeline which will:
# - Run BATS tests
# - Build all three targets
# - Run image-specific tests
```

## 🐛 Test Troubleshooting

### BATS Test Failures

1. **Permission Issues**: Ensure scripts are executable

   ```bash
   chmod +x scripts/*.sh tests/test-*.sh
   ```

2. **Missing Dependencies**: Install BATS framework

   ```bash
   make install-bats
   ```

3. **Helper Issues**: Check `tests/helpers/common.bash` exists

### Configuration Test Failures

1. **Syntax Errors**: Validate PHP syntax manually

   ```bash
   php -l config/prod/php.ini
   ```

2. **Missing Settings**: Check configuration files exist

   ```bash
   ls -la config/prod/
   ```

### Security Test Failures

1. **Missing Security Settings**: Review production configuration
2. **User Issues**: Check Dockerfile user configuration
3. **Permission Problems**: Validate file ownership settings

### Docker Test Failures

1. **Build Issues**: Check Dockerfile syntax and referenced files
2. **Runtime Issues**: Validate configuration in containers
3. **Permission Issues**: Ensure correct user/permissions

## 📊 Test Coverage

### What's Tested

- ✅ **Configuration**: All PHP and FPM settings
- ✅ **Security**: Production security hardening
- ✅ **Performance**: OPcache and FPM optimization
- ✅ **Docker Structure**: Multi-stage build correctness
- ✅ **Script Quality**: Shell script validation
- ✅ **File Permissions**: Executable and ownership checks

### What's Not Tested (By Design)

- ❌ **Application Logic**: This is an image project, not an application
- ❌ **External Services**: No database/cache integration tests
- ❌ **Complex Performance**: No load testing (out of scope)
- ❌ **Network Security**: Basic validation only

## 🚀 Continuous Integration

The GitLab CI pipeline runs:

1. **Security Stage**: Secret detection
2. **Validation Stage**: Hadolint, markdownlint, shellcheck
3. **Test Stage**: All BATS tests
4. **Build Stage**: Multi-target Docker builds (on tags)

### CI Test Commands

```bash
# What CI runs automatically
make quality   # Linting and validation
make bats      # All BATS tests
```

## 📝 Adding New Tests

### Adding BATS Tests

1. Create new `.bats` file in appropriate directory
2. Load common helpers: `load "../helpers/common"`
3. Use descriptive test names
4. Follow existing test patterns

### Adding Validation Scripts

1. Create shell script in `scripts/`
2. Use `set -euo pipefail` for error handling
3. Add proper error messages and exit codes
4. Make executable with `chmod +x`
5. Add to `tools/make/local.mk` as new target

### Example New Test

```bash
# tests/integration/22-new-feature.bats
#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

@test "New feature is properly configured" {
  run grep -q "setting = value" "${PROJECT_ROOT}/config/prod/file.conf"
  [[ "$status" -eq 0 ]]
}
```
