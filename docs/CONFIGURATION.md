# Configuration Documentation

This document explains the PHP configuration structure used in this Docker image project.

## 📁 Configuration Structure

### Production Environment (`config/prod/`)

- **`php.ini`** - Core PHP settings with security hardening
- **`fpm.conf`** - PHP-FPM process manager configuration
- **`opcache.ini`** - OPcache performance optimization settings

### Development Environment (`config/dev/`)

- **`php.ini`** - Development-friendly PHP settings
- **`xdebug.ini`** - Xdebug debugging configuration

### Test Environment (`config/test/`)

- **`php.ini`** - Test environment PHP settings
- **`pcov.ini`** - PCOV code coverage configuration

## 🔒 Security Configuration

### Production Security Features

```ini
; File access restrictions
allow_url_fopen = Off
allow_url_include = Off
open_basedir = /var/www/html:/tmp:/var/lib/php/sessions

; Function restrictions
disable_functions = exec,passthru,shell_exec,system,proc_open,popen

; Information hiding
expose_php = Off
```

### Session Security

```ini
; Secure session settings
session.cookie_secure = On
session.cookie_httponly = On
session.cookie_samesite = Strict
session.use_strict_mode = On
```

### User Security

- All containers run as non-root user `www` (UID 1000)
- Configuration files owned by `root:root`
- Application files owned by `www:www`

## ⚡ Performance Configuration

### OPcache Optimization

```ini
; Memory allocation
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16

; Performance settings
opcache.validate_timestamps = 0  ; Production only
opcache.max_accelerated_files = 20000

; JIT compilation
opcache.jit_buffer_size = 128M
opcache.jit = tracing
```

### FPM Process Management

```ini
; Dynamic process manager
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.max_requests = 1000
```

## 🐛 Development Configuration

### Relaxed Security for Development

```ini
; Development-friendly settings
allow_url_fopen = On
display_errors = On
display_startup_errors = On
error_reporting = E_ALL
```

### Xdebug Configuration

```ini
; Xdebug modes
xdebug.mode = develop,debug,coverage
xdebug.start_with_request = yes
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
```

## 🧪 Test Configuration

### Code Coverage

```ini
; PCOV settings
pcov.enabled = 1
pcov.directory = /var/www/html
pcov.exclude = "~vendor~"
```

## 🔄 Environment Differences

| Setting | Production | Development | Test |
| ------- | ---------- | ------------ | ----- |
| `display_errors` | Off | On | Off |
| `allow_url_fopen` | Off | On | Off |
| `expose_php` | Off | On | Off |
| `OPcache timestamps` | Disabled | Enabled | Disabled |
| Extensions | Core only | + Xdebug | + PCOV |

## 📋 Configuration Validation

The project includes validation scripts to ensure configuration consistency:

```bash
# Validate all configuration files
make test-config

# Validate security settings
make test-security

# Validate Docker structure
make test-docker

# Run complete validation
make test-complete
```

## 🛠️ Configuration Customization

### Adding New PHP Extensions

1. Update `Dockerfile` base stage:

   ```dockerfile
   docker-php-ext-install -j"$(nproc)" new_extension
   ```

2. Add extension-specific configuration to appropriate environment files

### Modifying Security Settings

1. Update `config/prod/php.ini` for security changes
2. Update `config/prod/fpm.conf` for FPM security
3. Run validation: `make test-security`

### Performance Tuning

1. Adjust `config/prod/opcache.ini` for OPcache settings
2. Modify `config/prod/fpm.conf` for FPM tuning
3. Test with performance validation scripts

## 🔧 Troubleshooting

### Configuration Issues

1. **Syntax Errors**: Run `make test-config` to validate
2. **Security Issues**: Run `make test-security` to audit
3. **Performance Issues**: Check OPcache and FPM settings

### Extension Problems

1. Verify extension installation in Dockerfile
2. Check extension-specific configuration files
3. Validate with BATS tests

### Docker Build Issues

1. Check configuration file existence: `make test-docker`
2. Verify file permissions in Dockerfile
3. Validate Docker structure with validation scripts
