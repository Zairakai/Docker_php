#!/usr/bin/env bats

bats_require_minimum_version 1.5.0
load "../helpers/common"

# =============================================================================
# CONFIGURATION FILES - Validation des fichiers de configuration PHP
# =============================================================================

@test "Production configuration files exist" {
  [[ -f "${PROJECT_ROOT}/config/prod/php.ini" ]]
  [[ -f "${PROJECT_ROOT}/config/prod/fpm.conf" ]]
  [[ -f "${PROJECT_ROOT}/config/prod/opcache.ini" ]]
}

@test "Development configuration files exist" {
  [[ -f "${PROJECT_ROOT}/config/dev/php.ini" ]]
  [[ -f "${PROJECT_ROOT}/config/dev/xdebug.ini" ]]
}

@test "Test configuration files exist" {
  [[ -f "${PROJECT_ROOT}/config/test/php.ini" ]]
  [[ -f "${PROJECT_ROOT}/config/test/pcov.ini" ]]
}

@test "Production PHP configuration has proper security settings" {
  run grep -q "allow_url_fopen = Off" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "disable_functions" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "open_basedir" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
}

@test "Production PHP configuration has proper session security" {
  run grep -q "session.cookie_secure = On" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "session.cookie_samesite = Strict" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "session.use_strict_mode = On" "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
}

@test "Production FPM configuration has proper process manager settings" {
  run grep -q "pm = dynamic" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
  
  run grep -q "pm.max_children = 50" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
  
  run grep -q "pm.max_requests = 1000" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
}

@test "Production FPM configuration has security settings" {
  run grep -q "user = www" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
  
  run grep -q "group = www" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
  
  run grep -q "clear_env = yes" "${PROJECT_ROOT}/config/prod/fpm.conf"
  [[ "$status" -eq 0 ]]
}

@test "Production OPcache configuration is optimized" {
  run grep -q "opcache.enable = 1" "${PROJECT_ROOT}/config/prod/opcache.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "opcache.validate_timestamps = 0" "${PROJECT_ROOT}/config/prod/opcache.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "opcache.jit_buffer_size = 128M" "${PROJECT_ROOT}/config/prod/opcache.ini"
  [[ "$status" -eq 0 ]]
}

@test "Development configuration allows URL access" {
  run grep -q "allow_url_fopen = On" "${PROJECT_ROOT}/config/dev/php.ini"
  [[ "$status" -eq 0 ]]
}

@test "Development configuration enables error display" {
  run grep -q "display_errors = On" "${PROJECT_ROOT}/config/dev/php.ini"
  [[ "$status" -eq 0 ]]
}

@test "Development Xdebug configuration is properly set" {
  run grep -q "xdebug.mode = develop,debug,coverage" "${PROJECT_ROOT}/config/dev/xdebug.ini"
  [[ "$status" -eq 0 ]]
  
  run grep -q "xdebug.start_with_request = yes" "${PROJECT_ROOT}/config/dev/xdebug.ini"
  [[ "$status" -eq 0 ]]
}

@test "Test configuration enables PCOV" {
  run grep -q "pcov.enabled = 1" "${PROJECT_ROOT}/config/test/pcov.ini"
  [[ "$status" -eq 0 ]]
}

@test "Configuration files have proper syntax" {
  # Test PHP ini syntax
  run php -l "${PROJECT_ROOT}/config/prod/php.ini"
  [[ "$status" -eq 0 ]]
  
  run php -l "${PROJECT_ROOT}/config/dev/php.ini"
  [[ "$status" -eq 0 ]]
  
  run php -l "${PROJECT_ROOT}/config/test/php.ini"
  [[ "$status" -eq 0 ]]
}