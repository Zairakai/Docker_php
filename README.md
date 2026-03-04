# Zairakai PHP 8.3 Docker Image

[![Main][pipeline-main-badge]][pipeline-main-link]
[![Security][security-badge]][security]

[![License][license-badge]][license]
[![PHP][php-badge]][php]
[![Release][release-badge]][release]

[![Docker Pulls][docker-pulls-badge]][dockerhub]
[![Prod Image Size][docker-prod-size-badge]][dockerhub]
[![Dev Image Size][docker-dev-size-badge]][dockerhub]
[![Test Image Size][docker-test-size-badge]][dockerhub]

Lightweight, secure, and optimized PHP 8.3 FPM images designed for **Laravel** applications.

Production-ready PHP 8.3 FPM image with multi-stage builds for production, development, and testing.

## Features

### Production Stage (`prod`)

- PHP 8.3 FPM on Alpine Linux
- Essential extensions: Redis, PDO MySQL/PostgreSQL, GD, Zip, Intl, BCMath, OPcache
- Composer 2
- OPcache optimized for production with JIT compilation
- Health check via PHP-FPM ping
- Non-root user (`www:www`)
- **Performance Monitoring**: Real-time metrics and health endpoints
- **Security Hardening**: Runtime security validation and vulnerability scanning
- **FPM Optimization**: Dynamic process manager tuning for system resources

### Development Stage (`dev`)

- All production features
- Xdebug for debugging and coverage
- Development tools: Git, Vim, Curl, Wget
- Database clients: MySQL, PostgreSQL, Redis
- OPcache with validate_timestamps enabled
- Extended error reporting

### Test Stage (`test`)

- All production features
- PCOV for fast code coverage
- Testing environment optimized

## 🚀 Quick Start

```bash
# Pull and run
docker run -d --name php-fpm -p 9000:9000 zairakai/php:prod

# Health check
curl http://localhost:9000/ping
# Response: pong

# Quick validation
make quick-test
```

## Available Tags

| Version | Production | Development | Test |
| --- | --- | --- | --- |
| **Patch** | `zairakai/php:1.2.3` | `zairakai/php:1.2.3-dev` | `zairakai/php:1.2.3-test` |
| **Minor** | `zairakai/php:1.2` | `zairakai/php:1.2-dev` | `zairakai/php:1.2-test` |
| **Major** | `zairakai/php:1` | `zairakai/php:1-dev` | `zairakai/php:1-test` |
| **Latest** | `zairakai/php:latest` | `zairakai/php:latest-dev` | `zairakai/php:latest-test` |

## Usage

### Production

```yaml
# docker-compose.yml
services:
  php:
    image: zairakai/php:latest
    volumes:
      - ./:/var/www/html
    environment:
      - APP_ENV=production
```

### Development

```yaml
services:
  php:
    image: zairakai/php:latest-dev
    volumes:
      - ./:/var/www/html
    environment:
      - APP_ENV=local
```

### Testing

```yaml
services:
  php:
    image: zairakai/php:latest-test
    volumes:
      - ./:/var/www/html
    environment:
      - APP_ENV=testing
```

## Configuration

### Custom PHP Settings

Mount your own `php.ini`:

```yaml
volumes:
  - ./custom-php.ini:/usr/local/etc/php/conf.d/custom.ini
```

### Custom FPM Settings

Mount your own FPM config:

```yaml
volumes:
  - ./custom-fpm.conf:/usr/local/etc/php-fpm.d/zz-custom.conf
```

## Health Check

The image includes a health check that pings PHP-FPM:

```bash
docker inspect --format='{{.State.Health.Status}}' <container-id>
```

---

## Development

### Prerequisites

- Git
- Docker
- GNU Make (optional, for running tests)

### Clone the Repository

This repository uses Git submodules for shared tooling. Clone with:

```bash
# Clone with submodules in one command
git clone --recurse-submodules https://gitlab.com/zairakai/dockers/php.git

# OR if already cloned without submodules
git clone https://gitlab.com/zairakai/dockers/php.git
cd php
git submodule update --init --recursive
```

### Update Submodules

To update the `tooling` submodule to the latest version:

```bash
git submodule update --remote --merge
```

### Build Images Locally

```bash
# Build production image
docker build --target prod -t zairakai/php:local .

# Build development image
docker build --target dev -t zairakai/php:local-dev .

# Build test image
docker build --target test -t zairakai/php:local-test .
```

### Run Tests

```bash
# Run BATS tests (requires submodules)
make bats

# Or manually
bats tests/
```

### CI/CD Pipeline

The project uses GitLab CI/CD with the following stages:

1. **Security** - Secret detection
2. **Validate** - Dockerfile linting (Hadolint), Markdown linting, Shellcheck
3. **Test** - BATS test suite
4. **Build** - Multi-stage Docker builds (prod/dev/test)
5. **Release** - Automated GitLab releases with changelog

---

## 🔒 Security

- ✅ Non-root user (www)
- ✅ OPcache optimized
- ✅ Security headers
- ✅ Resource limits

```bash
# Quick security check
make quick-security

# Security validation
make validate-dockerfile
```

---

## 🧪 Testing

```bash
# Quick validation
make quick-test

# Test image
make test-image
```

### Simple Metrics

```bash
# Health check
make health-check

# Basic metrics
make metrics

# Quick validation
make quick-test
```

```bash
# Local development testing
make test-local           # Complete local validation
make validate-dockerfile  # Quick Dockerfile checks
make test-essential-scripts # Test critical scripts

# Image testing (requires Docker)
make test-prod           # Test production image
make test-dev            # Test development image
make test-test           # Test test image

# Quality checks
make quality             # Run all quality checks
make bats                # Run BATS tests
```

### Test Categories

| Test Type | Command | Description |
| --------- | ------- | ----------- |
| Local Tests | `make test-local` | Complete validation without Docker |
| Docker Tests | `make test-image` | All 3 Docker targets |
| Quality | `make quality` | Linting and validation |
| BATS | `make bats` | BATS test suite |

---

## 📚 Quick Reference

```bash
# All available commands
make help

# Local development
make test-local          # Complete local validation
make quick-test          # Quick health check

# Image testing
make test-prod           # Test production image
make test-dev            # Test development image
make test-test           # Test image

# Quality checks
make quality             # Run all quality checks
make ci-full             # Complete validation
```

---

## Getting Help

[![License][license-badge]][license]
[![Security Policy][security-badge]][security]
[![Issues][issues-badge]][issues]

---

**Made with ❤️ by [Zairakai][ecosystem]**

<!-- Reference Links -->
[pipeline-main-badge]: https://gitlab.com/zairakai/dockers/php/badges/main/pipeline.svg?ignore_skipped=true&key_text=Main
[pipeline-main-link]: https://gitlab.com/zairakai/dockers/php/-/commits/main
[license-badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license]: ./LICENSE
[php-badge]: https://img.shields.io/badge/php-8.3-blue.svg
[php]: https://www.php.net/
[release-badge]: https://img.shields.io/gitlab/v/release/zairakai%2Fdockers%2Fphp?logo=gitlab
[release]: https://gitlab.com/zairakai/dockers/php/-/releases
[issues-badge]: https://img.shields.io/gitlab/issues/open-raw/zairakai%2Fdockers%2Fphp?logo=gitlab&label=Issues
[issues]: https://gitlab.com/zairakai/dockers/php/-/issues
[security-badge]: https://img.shields.io/badge/security-scanned-green.svg
[security]: ./SECURITY.md
[docker-pulls-badge]: https://img.shields.io/docker/pulls/zairakai/php?logo=docker
[dockerhub]: https://hub.docker.com/r/zairakai/php
[docker-prod-size-badge]: https://img.shields.io/docker/image-size/zairakai/php/latest?logo=docker&label=prod
[docker-dev-size-badge]: https://img.shields.io/docker/image-size/zairakai/php/latest-dev?logo=docker&label=dev
[docker-test-size-badge]: https://img.shields.io/docker/image-size/zairakai/php/latest-test?logo=docker&label=test
[ecosystem]: https://gitlab.com/zairakai/dockers
